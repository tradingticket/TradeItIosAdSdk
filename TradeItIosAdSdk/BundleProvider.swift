import Foundation

class BundleProvider {
    func provideBundle(withName bundleName: String) -> Bundle {
        let frameworkBundle = self.frameworkBundle(withName: bundleName)
        if let resourceBundlePath = frameworkBundle.path(forResource: bundleName, ofType: "bundle"),
            let resourceBundle = Bundle.init(path: resourceBundlePath) {
            return resourceBundle
        } else {
            return frameworkBundle
        }
    }

    func frameworkBundle(withName bundleName: String) -> Bundle {
        if let bundle = Bundle.init(identifier: "org.cocoapods.\(bundleName)") {
            return bundle
        } else {
            return Bundle.init(for: type(of: self))
        }
    }
}
