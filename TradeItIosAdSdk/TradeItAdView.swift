import UIKit

public class TradeItAdView: UIView {
    @IBOutlet var webView: UIWebView!
    @IBOutlet var view: UIView!

    let webViewDelegate: WebViewDelegate = WebViewDelegate()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    public func configureWithAdType(adType: String, broker: String?, heightConstraint: NSLayoutConstraint?) {
        let setHeightConstraintTo = { (height: CGFloat) -> Void in
            guard let heightConstraint = heightConstraint else { return }
            dispatch_async(dispatch_get_main_queue(), {
                heightConstraint.constant = height
            })
        }

        if(TradeItAdConfig.enabled) {
            AdService.getAdForAdType(adType, broker: broker, callback: { (response: Result) -> Void in
                switch response {
                case let .Success(ad):
                    guard let adId = ad["adId"] as? Int else { return }
                    let url = "\(TradeItAdConfig.baseUrl)mobile/getAdUnit?placementId=\(adId)"
                    guard let nsurl = NSURL(string: url) else { return }
                    guard let height = ad["adHeight"] as? CGFloat else { return }
                    let requestObj = NSURLRequest(URL: nsurl)
                    self.webView.loadRequest(requestObj)
                    setHeightConstraintTo(height)
                case let .Failure(error):
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
    public func configureWithAdType(adType: String) {
        configureWithAdType(adType, broker: nil, heightConstraint: nil)
    }

    public func configureWithAdType(adType: String, broker: String) {
        configureWithAdType(adType, broker: broker, heightConstraint: nil)
    }

    public func configureWithAdType(adType: String, heightConstraint: NSLayoutConstraint?) {
        configureWithAdType(adType, broker: nil, heightConstraint: heightConstraint)
    }

    func xibSetup() {
        loadViewFromNib()
        view.frame = bounds
        webView.frame = bounds
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        webView.delegate = webViewDelegate
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        return NSBundle(forClass: self.dynamicType).loadNibNamed("TradeItAdView", owner: self, options: nil)[0] as! UIView
    }
}

class WebViewDelegate: NSObject, UIWebViewDelegate {
    @objc func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Clicking on the ad doesn't trigger a navigationType = .LinkClicked
        guard let url = request.URL else { return true }
        if url.host == "adclick.g.doubleclick.net" {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        return true
    }
}
