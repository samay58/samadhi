import SwiftUI

public enum SamadhiColor {
    public static let parchment = Color(red: 0.956, green: 0.929, blue: 0.878)
    public static let ivory = Color(red: 0.988, green: 0.969, blue: 0.925)
    public static let ink = Color(red: 0.137, green: 0.114, blue: 0.106)
    public static let plum = Color(red: 0.264, green: 0.188, blue: 0.204)
    public static let clay = Color(red: 0.733, green: 0.345, blue: 0.208)
    public static let apricot = Color(red: 0.882, green: 0.596, blue: 0.365)
    public static let olive = Color(red: 0.365, green: 0.424, blue: 0.306)
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
    public static let immediate = 0.09
    public static let control = 0.18
    public static let transition = 0.42
    public static let settle = 0.65
}
