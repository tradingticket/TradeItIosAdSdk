import UIKit

public class TradeItAdView: UIView {
    @IBOutlet var webView: UIWebView!
    @IBOutlet var view: UIView!

    let webViewDelegate: WebViewDelegate = WebViewDelegate()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    // Helper for ObjC because it does not support default parameters
    public func initializeWithApiKey(apiKey: String, location: String, broker: String) {
        initializeWithApiKey(apiKey, location: location, broker: broker, heightConstraint: nil)
    }

    public func initializeWithApiKey(apiKey: String, location: String, broker: String, heightConstraint: NSLayoutConstraint? = nil) {
        let adService = AdService(apiKey: apiKey)

        let collapseHeightConstraintTo = { (height: CGFloat) -> Void in
            guard let heightConstraint = heightConstraint else { return }
            dispatch_async(dispatch_get_main_queue(), {
                heightConstraint.constant = height
            })
        }
        adService.getAdForLocation(location, broker:broker, callback: { (response: Response) -> Void in
            switch response {
            case let .Success(ad):
                print(ad)
                guard let url = ad["adUrl"] as? String else { return }
                guard let nsurl = NSURL(string: url) else { return }
                guard let height = ad["adHeight"] as? CGFloat else { return }
                let requestObj = NSURLRequest(URL: nsurl)
                self.webView.loadRequest(requestObj)
                collapseHeightConstraintTo(height)
            case let .Failure(error):
                print("Error: \(error)")
                collapseHeightConstraintTo(0)
            }
        })
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
