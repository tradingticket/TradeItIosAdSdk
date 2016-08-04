@objc public class TradeItAdConfig: NSObject {
    public static var apiKey: String?
    public static var users: [[String: String]] = []
    public static var environment = TradeItAdEnvironment.QA
    public static var debug = false
    public static var deviceInfoOverride: String?

    static var baseUrl: String {
        switch environment {
        case .Local: return "http://localhost:8080/ad/v1/"
        case .Production: return "https://ems.tradingticket.com/ad/v1/"
        default: return "https://ems.qa.tradingticket.com/ad/v1/"
        }
    }

    static func log(message: String) {
        if debug {
            print("[TradeItAdSdk] \(message)")
        }
    }
}
