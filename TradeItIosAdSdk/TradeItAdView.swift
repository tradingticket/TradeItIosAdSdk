import UIKit

open class TradeItAdView: UIView {
    @IBOutlet var webView: UIWebView!
    @IBOutlet var view: UIView!
    let bundleProvider = BundleProvider()

    let webViewDelegate: WebViewDelegate = WebViewDelegate()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    open func configureWithAdType(_ adType: String, broker: String?, heightConstraint: NSLayoutConstraint?) {
        let setHeightConstraintTo = { (height: CGFloat) -> Void in
            guard let heightConstraint = heightConstraint else { return }
            DispatchQueue.main.async(execute: {
                heightConstraint.constant = height
            })
        }

        if (TradeItAdConfig.enabled) {
            AdService.getAdForAdType(adType, broker: broker, callback: { (response: Result) -> Void in
                switch response {
                case let .success(ad):
                    guard let adId = ad["adId"] as? Int else { return }
                    let url = "\(TradeItAdConfig.baseUrl)mobile/getAdUnit?placementId=\(adId)"
                    guard let nsurl = URL(string: url) else { return }
                    guard let height = ad["adHeight"] as? CGFloat else { return }
                    let requestObj = URLRequest(url: nsurl)
                    self.webView.loadRequest(requestObj)
                    setHeightConstraintTo(height)
                case let .failure(error):
                    TradeItAdConfig.log("\(error)")
                    setHeightConstraintTo(0)
                }
            })
        } else {
            TradeItAdConfig.log("Collapsing ad view because TradeItAdConfig.enabled is false")
            setHeightConstraintTo(0)
        }
    }

    /* Helpers are for ObjC because it does not support default parameters */
    open func configureWithAdType(_ adType: String) {
        configureWithAdType(adType, broker: nil, heightConstraint: nil)
    }

    open func configureWithAdType(_ adType: String, broker: String) {
        configureWithAdType(adType, broker: broker, heightConstraint: nil)
    }

    open func configureWithAdType(_ adType: String, heightConstraint: NSLayoutConstraint?) {
        configureWithAdType(adType, broker: nil, heightConstraint: heightConstraint)
    }

    func xibSetup() {
        loadViewFromNib()
        view.frame = bounds
        webView.frame = bounds
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.delegate = webViewDelegate
        addSubview(view)
    }

    func loadViewFromNib() {
        let bundle = bundleProvider.provideBundle(withName: "TradeItIosAdSdk")

        if bundle.path(forResource: "TradeItAdView", ofType: "nib") != nil {
            bundle.loadNibNamed("TradeItAdView", owner: self, options: nil)
        } else {
            print("Error: Could not load TradeItAdView nib")
        }
    }
}

class WebViewDelegate: NSObject, UIWebViewDelegate {
    @objc func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Clicking on the ad doesn't trigger a navigationType = .LinkClicked
        guard let url = request.url else { return true }
        if url.host == "adclick.g.doubleclick.net" {
            UIApplication.shared.openURL(url)
            return false
        }
        return true
    }
}
