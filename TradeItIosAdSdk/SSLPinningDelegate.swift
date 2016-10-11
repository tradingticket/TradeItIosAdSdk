import Foundation

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    @objc func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

        if(!isLocal() && isServerTrusted(challenge, serverTrust: serverTrust) && isSSLCertificateMatching(certificate)) {
            let credential:URLCredential = URLCredential(trust: serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            TradeItAdConfig.log("SSL Pinning: SSL certificate match failed. Try upgrading to the latest TradeItAdSdk.")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    func isLocal() -> Bool {
        return TradeItAdConfig.environment == .local
    }

    func isServerTrusted(_ challenge: URLAuthenticationChallenge, serverTrust: SecTrust?) -> Bool {
        // Set SSL policies for domain name check
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString?)))
        SecTrustSetPolicies(serverTrust!, policies);

        // Evaluate server certificate
        #if swift(>=2.3)
            var result: SecTrustResultType = SecTrustResultType.invalid
            SecTrustEvaluate(serverTrust!, &result)
            return (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
        #else
            var result: SecTrustResultType = 0
            SecTrustEvaluate(serverTrust!, &result)
            return (Int(result) == SecTrustResultType.unspecified || Int(result) == SecTrustResultType.proceed)
        #endif
    }

    func isSSLCertificateMatching(_ certificate: SecCertificate?) -> Bool {
        guard let certificate = certificate else {
            TradeItAdConfig.log("Certificate from the SSL request is missing.")
            return false
        }
        guard let pathToPinnedServerCertificate = TradeItAdConfig.pathToPinnedServerCertificate() else {
            TradeItAdConfig.log("Path to pinned server certificate is missing.")
            return false
        }
        guard let localCertificate:Data = try? Data(contentsOf: URL(fileURLWithPath: pathToPinnedServerCertificate)) else {
            TradeItAdConfig.log("Pinned SSL certificate is missing. Try upgrading to the latest TradeItAdSdk.")
            return false
        }

        let remoteCertificate:Data = SecCertificateCopyData(certificate) as Data
        return (remoteCertificate == localCertificate)
    }
}
