import UIKit

public class TradeItIosAdView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var webView: UIWebView!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        loadContent()
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        return NSBundle(forClass: self.dynamicType).loadNibNamed("TradeItIosAdView", owner: self, options: nil)[0] as! UIView
    }

    func loadContent() {
        let url = NSURL(string: "https://www.trade.it")
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj);
    }
}
