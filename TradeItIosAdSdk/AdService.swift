import Foundation
import UIKit

enum Result {
    case success([String: AnyObject])
    case failure(TradeItAdError)
}

class AdService {
    static var ads: [String: AnyObject]?
    static var deviceInfo: String?

    static func getAllAds(_ callback: @escaping (Result) -> Void) {
        if let ads = ads { return callback(.success(ads)) }

        guard let apiKey = TradeItAdConfig.apiKey else { return callback(.failure(.missingConfig("apiKey"))) }
        let endpoint = TradeItAdConfig.baseUrl + "mobile/getAllAdsInfo"
        let urlBuilderOptional = URLComponents(string: endpoint)
        guard let url = urlBuilderOptional?.url else { return callback(.failure(.requestError("Endpoint invalid: \(endpoint)"))) }
        let object: NSDictionary = [
            "apiKey": apiKey,
            "users": TradeItAdConfig.users,
            "device": device(),
            "modelNumber": modelNumber(),
            "os": os(),
            "width": width()
        ]
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: SSLPinningDelegate(), delegateQueue: nil)

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = toJSON(object)

        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let error = error { return callback(.failure(.unknownError(error.localizedDescription))) }
            guard let responseData = data else { return callback(.failure(.unknownError("Failed to read response"))) }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject]
                ads = jsonResponse?["admap"] as? [String: AnyObject]
                guard let ads = ads else { return callback(.failure(.jsonParseError)) }
                TradeItAdConfig.log("\(ads)")
                return callback(.success(ads))
            } catch let error {
                return callback(.failure(.unknownError("\(error)")))
            }
        }) 
        task.resume()
    }

    static func getAdForAdType(_ adType: String, callback: @escaping (Result) -> Void) {
        getAllAds({(result: Result) in
            switch result {
            case let .success(ads):
                if let adsForType = ads[adType] as? [String: AnyObject] {
                    return callback(.success(adsForType))
                } else if let adsForType = ads["general"] as? [String: AnyObject] {
                    TradeItAdConfig.log("No data in response for adType: \(adType). Defaulting to: general")
                    return callback(.success(adsForType))
                } else {
                    return callback(.failure(.missingAdType("No data in response for adType: \(adType) or general")))
                }
            case let .failure(error):
                return callback(.failure(error))
            }
        })
    }

    static func getAdForAdType(_ adType: String, broker: String?, callback: @escaping (Result) -> Void) {
        getAdForAdType(adType, callback: {(result: Result) in
            switch result {
            case let .success(ads):
                let broker = broker ?? "all"
                if let adForBroker = ads[broker] as? [String: AnyObject] {
                    return callback(.success(adForBroker))
                } else if let adForBroker = ads["all"] as? [String: AnyObject] {
                    TradeItAdConfig.log("No data in response for broker: \(broker). Defaulting to: all")
                    return callback(.success(adForBroker))
                } else {
                    return callback(.failure(.unknownError("No data in response for broker: \(broker) or all")))
                }
            case let .failure(error):
                return callback(.failure(error))
            }
        })
    }

    static func modelNumber() -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(\\d.*)", options: [])
            let nsString = getDeviceInfo() as NSString
            let results = regex.matches(in: getDeviceInfo(), options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range) }.joined(separator: "")
        } catch {
            return getDeviceInfo()
        }
    }

    static func device() -> String {
        return getDeviceInfo().replacingOccurrences(of: modelNumber(), with: "").lowercased()
    }

    static func getDeviceInfo() -> String {
        if let override = TradeItAdConfig.deviceInfoOverride { return override }
        if let deviceInfo = self.deviceInfo { return deviceInfo }

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let deviceInfo = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return deviceInfo
    }

    static func os() -> String {
        return UIDevice.current.systemVersion
    }

    static func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    static func toJSON(_ object: NSDictionary) -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        } catch {
            TradeItAdConfig.log("Error: Serializing data to JSON failed")
            return Data()
        }
    }
}
