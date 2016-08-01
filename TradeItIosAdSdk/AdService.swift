import Foundation

enum TradeItAdError: ErrorType {
    case RequestError(String)
    case JSONParseError
    case UnknownError
}

@objc public enum TradeItAdLocation: Int {
    case General
    case Account
    case Ticket
    // Have to use this instead of enum TradeItAdLocation: String to support ObjC
    func toString() -> String {
        switch self {
        case .Account: return "account"
        case .General: return "general"
        case .Ticket: return "ticket"
        }
    }
}

enum Response {
    case Success([String: AnyObject])
    case Failure(TradeItAdError)
}

class AdService {
    let urlComponents = NSURLComponents()
    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.port = 8080
        urlComponents.path = "/ad/v1/mobile/getAdInfo"
    }

    func getAd(location: TradeItAdLocation, callback: Response -> Void) {
        urlComponents.queryItems = [
            NSURLQueryItem(name: "apiKey", value: apiKey),
            NSURLQueryItem(name: "location", value: location.toString()),
            NSURLQueryItem(name: "os", value: os()),
            NSURLQueryItem(name: "device", value: device()),
        ]
        guard let url = urlComponents.URL else {
            return callback(.Failure(.RequestError("Endpoint is invalid: \(urlComponents.string)")))
        }

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