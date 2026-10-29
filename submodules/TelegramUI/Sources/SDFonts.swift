import UIKit
import ObjectiveC

// SD: Latin text uses Avenir Next (the same face as OC Pass); CJK falls back to the bundled
// Huninn typeface through a font cascade list, so English matches OC Pass and Chinese keeps
// the OC identity.
// Pass --sd-system-font (or SD_FONT_SWIZZLE=0) to disable.

extension UIFont {
    fileprivate static func sdAvenirName(_ weight: UIFont.Weight) -> String {
        switch weight {
        case .black, .heavy, .bold:
            return "AvenirNext-Bold"
        case .semibold:
            return "AvenirNext-DemiBold"
        case .medium:
            return "AvenirNext-Medium"
        default:
            return "AvenirNext-Regular"
        }
    }

    fileprivate static func sdCascaded(base: UIFont, size: CGFloat) -> UIFont {
        guard let huninn = UIFont(name: "Huninn-Regular", size: size) else {
            return base
        }
        let descriptor = base.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.cascadeList: [huninn.fontDescriptor]
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    @objc static func sd_systemFont(ofSize size: CGFloat) -> UIFont {
        let base = UIFont(name: UIFont.sdAvenirName(.regular), size: size)
            ?? UIFont.sd_systemFont(ofSize: size)
        return UIFont.sdCascaded(base: base, size: size)
    }

    @objc static func sd_systemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont(name: UIFont.sdAvenirName(weight), size: size)
            ?? UIFont.sd_systemFont(ofSize: size, weight: weight)
        return UIFont.sdCascaded(base: base, size: size)
    }
}

enum SDFontSwizzle {
    private static var installed = false

    static var isEnabled: Bool {
        if ProcessInfo.processInfo.arguments.contains("--sd-system-font") {
            return false
        }
        if let value = ProcessInfo.processInfo.environment["SD_FONT_SWIZZLE"], value == "0" {
            return false
        }
        return true
    }

    static func install() {
        guard !self.installed, self.isEnabled else {
            return
        }
        self.installed = true
        let cls: AnyClass = UIFont.self
        if let original = class_getClassMethod(cls, NSSelectorFromString("systemFontOfSize:")),
           let replacement = class_getClassMethod(cls, NSSelectorFromString("sd_systemFontOfSize:")) {
            method_exchangeImplementations(original, replacement)
        }
        if let original = class_getClassMethod(cls, NSSelectorFromString("systemFontOfSize:weight:")),
           let replacement = class_getClassMethod(cls, NSSelectorFromString("sd_systemFontOfSize:weight:")) {
            method_exchangeImplementations(original, replacement)
        }
        NSLog("SD-FONT-SWIZZLE installed")
    }
}
