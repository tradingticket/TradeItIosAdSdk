import Foundation

enum TradeItError: ErrorType {
    case RequestError(String)
    case JSONParseError
    case UnknownError
}

enum Response {
    case Success([String: AnyObject])
    case Failure(TradeItError)
}

class AdService {
    let baseEndpoint = "http://localhost:8080/ad/v1"
    
    func getAd(callback: Response -> Void) {
        let endpoint = "\(baseEndpoint)/mobile/getAdInfo?apiKey=tradeit-test-api-key&location=general&os=ios8&device=iphone&modelNumber=6plus"
        guard let url = NSURL(string: endpoint) else {
            return callback(.Failure(.RequestError("Endpoint is invalid: \(endpoint)")))
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
}