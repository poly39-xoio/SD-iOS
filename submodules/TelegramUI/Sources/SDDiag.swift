import UIKit

// SD: temporary runtime diagnostic - dumps rounded subviews so we can find the composer field.

enum SDDiag {
    static func start() {
        guard ProcessInfo.processInfo.arguments.contains("--sd-diag") else {
            return
        }
        var ticks = 0
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            ticks += 1
            if ticks > 60 {
                timer.invalidate()
                return
            }
            let scenes = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
            let allWindows = scenes.flatMap({ $0.windows })
            guard let window = allWindows.first(where: { $0.isKeyWindow }) ?? allWindows.first else {
                return
            }
            var found: [String] = []
            func walk(_ view: UIView, depth: Int) {
                if depth > 30 { return }
                let r = view.layer.cornerRadius
                let f = view.frame
                if r > 0.1 && f.height >= 20.0 && f.height <= 120.0 && f.width > 100.0 {
                    found.append("\(type(of: view)) r=\(Int(r)) w=\(Int(f.width)) h=\(Int(f.height))")
                }
                for sub in view.subviews { walk(sub, depth: depth + 1) }
            }
            walk(window, depth: 0)
            if !found.isEmpty {
                NSLog("SD-DIAG-ROUNDED %@", found.joined(separator: " | "))
            }
        }
    }
}
