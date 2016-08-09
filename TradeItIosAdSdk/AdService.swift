import Foundation
import UIKit

enum Result {
    case Success([String: AnyObject])
    case Failure(TradeItAdError)
}

class AdService {
    static var ads: [String: AnyObject]?
    static var deviceInfo: String?

    static func getAllAds(callback: Result -> Void) {
        if let ads = ads { return callback(.Success(ads)) }

        guard let apiKey = TradeItAdConfig.apiKey else { return callback(.Failure(.MissingConfig("apiKey"))) }
        let endpoint = TradeItAdConfig.baseUrl + "mobile/getAllAdsInfo"
        let urlBuilderOptional = NSURLComponents(string: endpoint)
        guard let url = urlBuilderOptional?.URL else { return callback(.Failure(.RequestError("Endpoint invalid: \(endpoint)"))) }
        let object: NSDictionary = [
            "apiKey": apiKey,
            "users": TradeItAdConfig.users,
            "device": device(),
            "modelNumber": modelNumber(),
            "os": os(),
            "width": width()
        ]
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: SSLPinningDelegate(), delegateQueue: nil)

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = toJSON(object)

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let error = error { return callback(.Failure(.UnknownError(error.localizedDescription))) }
            guard let responseData = data else { return callback(.Failure(.UnknownError("Failed to read response"))) }

            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject]
                ads = jsonResponse?["admap"] as? [String: AnyObject]
                guard let ads = ads else { return callback(.Failure(.JSONParseError)) }
                TradeItAdConfig.log("\(ads)")
                return callback(.Success(ads))
            } catch let error {
                return callback(.Failure(.UnknownError("\(error)")))
            }
        }
        task.resume()
    }

    static func getAdForAdType(adType: String, callback: Result -> Void) {
        getAllAds({(result: Result) in
            switch result {
            case let .Success(ads):
                if let adsForType = ads[adType] as? [String: AnyObject] {
                    return callback(.Success(adsForType))
                } else if let adsForType = ads["general"] as? [String: AnyObject] {
                    TradeItAdConfig.log("No data in response for adType: \(adType). Defaulting to: general")
                    return callback(.Success(adsForType))
                } else {
                    return callback(.Failure(.MissingAdType("No data in response for adType: \(adType) or general")))
                }
            case let .Failure(error):
                return callback(.Failure(error))
            }
        })
    }

    static func getAdForAdType(adType: String, broker: String?, callback: Result -> Void) {
        getAdForAdType(adType, callback: {(result: Result) in
            switch result {
            case let .Success(ads):
                let broker = broker ?? "all"
                if let adForBroker = ads[broker] as? [String: AnyObject] {
                    return callback(.Success(adForBroker))
                } else if let adForBroker = ads["all"] as? [String: AnyObject] {
                    TradeItAdConfig.log("No data in response for broker: \(broker). Defaulting to: all")
                    return callback(.Success(adForBroker))
                } else {
                    return callback(.Failure(.UnknownError("No data in response for broker: \(broker) or all")))
                }
            case let .Failure(error):
                return callback(.Failure(error))
            }
        })
    }

    static func modelNumber() -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(\\d.*)", options: [])
            let nsString = getDeviceInfo() as NSString
            let results = regex.matchesInString(getDeviceInfo(), options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range) }.joinWithSeparator("")
        } catch {
            return getDeviceInfo()
        }
    }

    static func device() -> String {
        return getDeviceInfo().stringByReplacingOccurrencesOfString(modelNumber(), withString: "").lowercaseString
    }

    static func getDeviceInfo() -> String {
        if let override = TradeItAdConfig.deviceInfoOverride { return override }
        if let deviceInfo = self.deviceInfo { return deviceInfo }

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let deviceInfo = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return deviceInfo
    }

    static func os() -> String {
        return UIDevice.currentDevice().systemVersion
    }

    static func width() -> CGFloat {
        return UIScreen.mainScreen().bounds.width
    }

    static func toJSON(object: NSDictionary) -> NSData {
        do {
            return try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
        } catch {
            TradeItAdConfig.log("Error: Serializing data to JSON failed")
            return NSData()
        }
    }
}