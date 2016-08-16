class BundleProvider {
    func provideBundle(withName bundleName: String) -> NSBundle {
        if let bundle = NSBundle.init(identifier: "org.cocoapods.\(bundleName)") {
            return bundle
        } else {
            let bundle = NSBundle.init(forClass: self.dynamicType)
            return bundle
        }
    }
}
