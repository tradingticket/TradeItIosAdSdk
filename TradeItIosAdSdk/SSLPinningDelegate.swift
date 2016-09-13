import Foundation

class SSLPinningDelegate: NSObject, NSURLSessionDelegate {
    @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

        if(!isLocal() && isServerTrusted(challenge, serverTrust: serverTrust) && isSSLCertificateMatching(certificate)) {
            let credential:NSURLCredential = NSURLCredential(forTrust: serverTrust!)
            completionHandler(.UseCredential, credential)
        } else {
            TradeItAdConfig.log("SSL Pinning: SSL certificate match failed. Try upgrading to the latest TradeItAdSdk.")
            completionHandler(.CancelAuthenticationChallenge, nil)
        }
    }

    func isLocal() -> Bool {
        return TradeItAdConfig.environment == .Local
    }

    func isServerTrusted(challenge: NSURLAuthenticationChallenge, serverTrust: SecTrust?) -> Bool {
        // Set SSL policies for domain name check
        let policies = NSMutableArray()
        policies.addObject(SecPolicyCreateSSL(true, (challenge.protectionSpace.host)))
        SecTrustSetPolicies(serverTrust!, policies);

        // Evaluate server certificate
        #if swift(>=2.3)
            var result: SecTrustResultType = SecTrustResultType.Invalid
            SecTrustEvaluate(serverTrust!, &result)
            return (result == SecTrustResultType.Unspecified || result == SecTrustResultType.Proceed)
        #else
            var result: SecTrustResultType = 0
            SecTrustEvaluate(serverTrust!, &result)
            return (Int(result) == kSecTrustResultUnspecified || Int(result) == kSecTrustResultProceed)
        #endif
    }

    func isSSLCertificateMatching(certificate: SecCertificate?) -> Bool {
        guard let certificate = certificate else {
            TradeItAdConfig.log("Certificate from the SSL request is missing.")
            return false
        }
        guard let pathToPinnedServerCertificate = TradeItAdConfig.pathToPinnedServerCertificate() else {
            TradeItAdConfig.log("Path to pinned server certificate is missing.")
            return false
        }
        guard let localCertificate:NSData = NSData(contentsOfFile: pathToPinnedServerCertificate) else {
            TradeItAdConfig.log("Pinned SSL certificate is missing. Try upgrading to the latest TradeItAdSdk.")
            return false
        }

        let remoteCertificate:NSData = SecCertificateCopyData(certificate)
        return remoteCertificate.isEqualToData(localCertificate)
    }
}
