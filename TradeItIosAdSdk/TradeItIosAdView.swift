import UIKit

class WebViewDelegate: NSObject, UIWebViewDelegate {
    @objc func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.URL else { return true }
        if url.host == "adclick.g.doubleclick.net" {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        return true
    }
}

public class TradeItIosAdView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var webView: UIWebView!
    
    let adService: AdService = AdService()
    let webViewDelegate: WebViewDelegate = WebViewDelegate()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        loadAd()
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        webView.frame = bounds
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        webView.delegate = webViewDelegate
        addSubview(view)
//        var device = UIDevice.currentDevice().
//        print(device)
    }

    func loadViewFromNib() -> UIView {
        return NSBundle(forClass: self.dynamicType).loadNibNamed("TradeItIosAdView", owner: self, options: nil)[0] as! UIView
    }

    func loadAd() {
        adService.getAd({ (ad: [String: AnyObject]) -> Void in
            guard let url = ad["adUrl"] as? String else { return }
            guard let nsurl = NSURL(string: url) else { return }
            let requestObj = NSURLRequest(URL: nsurl)
            self.webView.loadRequest(requestObj)
        })
    }
}
