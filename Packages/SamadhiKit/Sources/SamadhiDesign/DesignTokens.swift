import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

// Raw values live here so a test can hold every pairing to its contrast floor. Views use SamadhiColor.
enum Swatch {
    static let lime: UInt32 = 0xD8F24C
    static let groundDark: UInt32 = 0x0B0D08
    static let inkDark: UInt32 = 0xF2F1E6
    static let paperLight: UInt32 = 0xF4F0E7
    static let inkLight: UInt32 = 0x15170F
    static let moss: UInt32 = 0x566400
    static let lilacDark: UInt32 = 0xB8A9E8
    static let lilacDeep: UInt32 = 0x6E5C9E
}

// Lime fills and lilac marks are the only hues. Lime means go and live: the primary action and the music
// following the runner. Lilac means the runner took over: Manual and the hold that ends a run. Lime is too
// pale to read as a line on paper, so anything drawn thin uses `line`, which is moss in light mode.
public enum SamadhiColor {
    public static let ink = Color(light: Swatch.inkLight, dark: Swatch.inkDark)
    public static let paper = Color(light: Swatch.paperLight, dark: Swatch.groundDark)
    public static let lime = Color(hex: Swatch.lime)
    // Stays dark in both appearances, because lime is always bright.
    public static let onLime = Color(hex: Swatch.groundDark)
    public static let line = Color(light: Swatch.moss, dark: Swatch.lime)
    public static let lilac = Color(light: Swatch.lilacDeep, dark: Swatch.lilacDark)
    // Sits behind light text during the finish hold, so it never lightens with the appearance.
    public static let lilacFill = Color(hex: Swatch.lilacDeep)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    init(light: UInt32, dark: UInt32) {
        #if canImport(UIKit)
            self.init(
                uiColor: UIColor { traits in
                    UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
                })
        #elseif canImport(AppKit)
            self.init(
                nsColor: NSColor(name: nil) { appearance in
                    let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                    return NSColor(Color(hex: isDark ? dark : light))
                })
        #endif
    }
}

public enum Space {
    public static let x1: CGFloat = 4
    public static let x2: CGFloat = 8
    public static let x3: CGFloat = 12
    public static let x4: CGFloat = 16
    public static let x6: CGFloat = 24
    public static let x8: CGFloat = 32
    public static let x12: CGFloat = 48
}

public enum MotionToken {
    public static let feedback = 0.22
    public static let control = 0.18
    public static let transition = 0.42
    // Press compression and release. Short enough to read as pressure, not as animation.
    public static let press = 0.1
}
