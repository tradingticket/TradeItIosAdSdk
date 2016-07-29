import Foundation

class AdService {
    let baseEndpoint = "http://localhost:8080/ad/v1"
    
    func getAd() {
        let endpoint = "\(baseEndpoint)/mobile/getAdInfo?apiKey=tradeit-test-api-key&location=general&os=ios8&device=iphone&modelNumber=6plus"
        guard let url = NSURL(string: endpoint) else {
            print("Error: URL is invalid")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error)")
                return
            }
            guard let responseData = data else {
                print("Error: Did not receive data")
                return
            }
            
            do {
                guard let adJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                print("Response: \(adJSON)")
            } catch {
                print("Error: Parsing JSON failed")
                return
            }
        }
        task.resume()
        
    }
}