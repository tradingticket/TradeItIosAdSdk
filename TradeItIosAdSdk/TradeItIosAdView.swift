import UIKit

public class TradeItIosAdView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var webView: UIWebView!
    
    let adService: AdService = AdService()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        loadAd()
//        webView.automaticallyAdjustsScrollViewInsets = false
//        webView.opaque = false
//        webView.backgroundColor = UIColor.clearColor()
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        webView.frame = bounds
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        addSubview(view)
//        var device = UIDevice.currentDevice().
//        print(device)
    }

    func loadViewFromNib() -> UIView {
        return NSBundle(forClass: self.dynamicType).loadNibNamed("TradeItIosAdView", owner: self, options: nil)[0] as! UIView
    }

    func loadAd() {
        adService.getAd()
        let url = NSURL(string: "http://localhost:8080/ad/v1/mobile/getAdUnit?placementId=17")
//        let url = NSURL(string: "https://www.google.com")
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }
}
