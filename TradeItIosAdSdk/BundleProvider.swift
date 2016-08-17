class BundleProvider {
    func provideBundle(withName bundleName: String) -> NSBundle {
        let frameworkBundle = self.frameworkBundle(withName: bundleName)
        if let resourceBundlePath = frameworkBundle.pathForResource(bundleName, ofType: "bundle"),
            let resourceBundle = NSBundle.init(path: resourceBundlePath) {
            return resourceBundle
        } else {
            return frameworkBundle
        }
    }

    func frameworkBundle(withName bundleName: String) -> NSBundle {
        if let bundle = NSBundle.init(identifier: "org.cocoapods.\(bundleName)") {
            return bundle
        } else {
            return NSBundle.init(forClass: self.dynamicType)
        }
    }
}