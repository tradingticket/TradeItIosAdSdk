import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var adView: TradeItAdView!
    @IBOutlet weak var adViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        TradeItAdConfig.debug = true
        TradeItAdConfig.apiKey = "tradeit-test-api-key"
        TradeItAdConfig.environment = .qa
        self.adView.configureWithAdType("general", heightConstraint: self.adViewHeightConstraint)
    }
}

