import Foundation
import Testing

@testable import SamadhiDesign

private let textFloor = 4.5

// These pairings carry text or a thin line. If a palette change drops one below the floor, the change is wrong.
@Test func everyPaletteTextPairingHoldsItsContrast() {
    #expect(contrast(Swatch.inkLight, Swatch.paperLight) >= textFloor)
    #expect(contrast(Swatch.inkDark, Swatch.groundDark) >= textFloor)
    #expect(contrast(Swatch.groundDark, Swatch.lime) >= textFloor)
    #expect(contrast(Swatch.lime, Swatch.groundDark) >= textFloor)
    #expect(contrast(Swatch.moss, Swatch.paperLight) >= textFloor)
    #expect(contrast(Swatch.lilacDeep, Swatch.paperLight) >= textFloor)
    #expect(contrast(Swatch.lilacDark, Swatch.groundDark) >= textFloor)
    // The finish label sits on the hold's fill.
    #expect(contrast(Swatch.inkDark, Swatch.lilacDeep) >= textFloor)
}

private func contrast(_ first: UInt32, _ second: UInt32) -> Double {
    let (lighter, darker) = (max(luminance(first), luminance(second)), min(luminance(first), luminance(second)))
    return (lighter + 0.05) / (darker + 0.05)
}

private func luminance(_ hex: UInt32) -> Double {
    func channel(_ shift: UInt32) -> Double {
        let value = Double((hex >> shift) & 0xFF) / 255
        return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * channel(16) + 0.7152 * channel(8) + 0.0722 * channel(0)
}
