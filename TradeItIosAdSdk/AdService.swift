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
        guard let urlBuilder = urlBuilderOptional else { return callback(.Failure(.RequestError("BaseURL + path is invalid: \(endpoint)"))) }
        urlBuilder.queryItems = [
            NSURLQueryItem(name: "apiKey", value: apiKey),
            NSURLQueryItem(name: "location", value: adType),
            NSURLQueryItem(name: "os", value: os()),
            NSURLQueryItem(name: "device", value: device())
        ]
        guard let url = urlBuilder.URL else { return callback(.Failure(.RequestError("Endpoint is invalid: \(urlBuilder.string)"))) }

        let urlRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) in
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
}