import Foundation

enum Response {
    case Success([String: AnyObject])
    case Failure(TradeItAdError)
}

class AdService {
    func getAdForAdType(adType: String, callback: Response -> Void) {
        guard let apiKey = TradeItAdConfig.apiKey else { return callback(.Failure(.MissingConfig("TradeItAdConfig.apiKey is not set"))) }
        let endpoint = TradeItAdConfig.baseUrl + "mobile/getAdInfo"
        let urlBuilderOptional = NSURLComponents(string: endpoint)
        guard let url = urlBuilderOptional?.URL else { return callback(.Failure(.RequestError("BaseURL + path is invalid: \(endpoint)"))) }
        let object: NSDictionary = [
            "apiKey": apiKey,
            "users": TradeItAdConfig.users,
            "device": device(),
            "location": adType,
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
            if let error = error {
                return callback(.Failure(.RequestError(error.localizedDescription)))
            }
            guard let responseData = data else {
                return callback(.Failure(.JSONParseError))
            }

            do {
                guard let ad = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject] else {
                    return callback(.Failure(.JSONParseError))
                }

                callback(.Success(ad))
            } catch let error {
                print(error)
                callback(.Failure(.UnknownError))
            }
        }
        task.resume()
    }

    func device() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    func os() -> String {
        return UIDevice.currentDevice().systemVersion
    }

    func toJSON(object: NSDictionary) -> NSData {
        do {
            return try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
        } catch {
            print("Error!")
            return NSData()
        }
    }
}