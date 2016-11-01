import Foundation

@objc public class TradeItAdConfig: NSObject {
    public static var apiKey: String?
    public static var users: [[String: String]] = []
    public static var environment = TradeItAdEnvironment.prod
    public static var debug = false
    public static var deviceInfoOverride: String?
    public static var enabled = true
    static let bundleProvider = BundleProvider()

    static var baseUrl: String {
        switch environment {
        case .local: return "http://localhost:8080/ad/v1/"
        case .qa: return "https://ems.qa.tradingticket.com/ad/v1/"
        default: return "https://ems.tradingticket.com/ad/v1/"
        }
    }

    static func log(_ message: String) {
        if debug {
            print("[TradeItAdSdk] \(message)")
        }
    }

    static func pathToPinnedServerCertificate() -> String? {
        let bundle = bundleProvider.provideBundle(withName: "TradeItIosAdSdk")
        let file = { () -> String? in
            switch(environment) {
            case .prod: return "server-prod"
            case .qa: return "server-qa"
            default: return nil
            }
        }()
        return bundle.path(forResource: file, ofType: "der")
    }
}
