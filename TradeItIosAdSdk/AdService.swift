import Foundation

enum Result {
    case Success([String: AnyObject])
    case Failure(TradeItAdError)
}

class AdService {
    static var ads: [String: AnyObject]?
    static var deviceInfo: String?

    static func getAllAds(callback: Result -> Void) {
        if let ads = ads { return callback(.Success(ads)) }

        guard let apiKey = TradeItAdConfig.apiKey else { return }
        let endpoint = TradeItAdConfig.baseUrl + "mobile/getAllAdsInfo"
        let urlBuilderOptional = NSURLComponents(string: endpoint)
        guard let url = urlBuilderOptional?.URL else { return }
        let object: NSDictionary = [
            "apiKey": apiKey,
            "users": TradeItAdConfig.users,
            "device": device(),
            "modelNumber": modelNumber(),
            "os": os()
        ]
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = toJSON(object)

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if let error = error { return TradeItAdConfig.log(error.localizedDescription) }
            guard let responseData = data else { return TradeItAdConfig.log("Failed to read response") }

            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject]
                ads = jsonResponse?["admap"] as? [String: AnyObject]
                guard let ads = ads else { return callback(.Failure(.JSONParseError)) }
                TradeItAdConfig.log("\(ads)")
                callback(.Success(ads))
            } catch {
                callback(.Failure(.UnknownError))
            }
        }
        task.resume()
    }

    static func getAdForAdType(adType: String, broker: String?, callback: Result -> Void) {
        getAllAds({(result: Result) in
            switch result {
            case let .Success(ads):
                guard let adsForType = ads[adType] as? [String: AnyObject] else { return callback(.Failure(.UnknownError)) }
                let broker = broker ?? "all"
                guard let adForBroker = adsForType[broker] as? [String: AnyObject] else { return callback(.Failure(.UnknownError)) }
                callback(.Success(adForBroker))
            case let .Failure(error):
                callback(.Failure(error))
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
        return getDeviceInfo().stringByReplacingOccurrencesOfString(modelNumber(), withString: "")
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

    static func toJSON(object: NSDictionary) -> NSData {
        do {
            return try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
        } catch {
            TradeItAdConfig.log("Error: Serializing data to JSON failed")
            return NSData()
        }
    }
}