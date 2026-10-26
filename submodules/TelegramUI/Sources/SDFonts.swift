import UIKit
import ObjectiveC

// SD: route the system font to the bundled Huninn typeface so every screen uses the OC identity.
// Pass --sd-system-font (or SD_FONT_SWIZZLE=0) to disable.

extension UIFont {
    @objc static func sd_systemFont(ofSize size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Huninn-Regular", size: size) {
            return font
        }
        return UIFont.sd_systemFont(ofSize: size)
    }

    @objc static func sd_systemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        if let font = UIFont(name: "Huninn-Regular", size: size) {
            return font
        }
        return UIFont.sd_systemFont(ofSize: size, weight: weight)
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
