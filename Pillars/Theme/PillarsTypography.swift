import SwiftUI

/// Type system for Pillars.
///
/// Large editorial **serif** for display moments (the system score, screen titles) paired
/// with a clean sans for everything functional. This contrast is what keeps the app
/// from reading like a generic tracker.
enum PillarsFont {
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

enum PillarsTypography {
    /// Hero display, e.g. the Welcome title.
    static let displayXL = PillarsFont.serif(46, .semibold)
    /// Screen titles ("Today's Foundation").
    static let display = PillarsFont.serif(34, .semibold)
    /// Large section title.
    static let title = PillarsFont.serif(26, .medium)
    /// Smaller serif title.
    static let titleSmall = PillarsFont.serif(21, .medium)

    /// Strong functional label.
    static let headline = PillarsFont.sans(17, .semibold)
    /// Body copy.
    static let body = PillarsFont.sans(16, .regular)
    /// Slightly smaller body.
    static let callout = PillarsFont.sans(15, .regular)
    /// Captions and helper text.
    static let caption = PillarsFont.sans(13, .regular)
    /// Tiny uppercase overline (apply `.tracking()` and `.textCase(.uppercase)` at the site).
    static let overline = PillarsFont.sans(12, .semibold)
}

extension View {
    /// Overline styling: tracked, uppercased, tertiary.
    func pillarsOverline(_ color: Color = PillarsColors.secondaryText) -> some View {
        self.font(PillarsTypography.overline)
            .textCase(.uppercase)
            .tracking(2.2)
            .foregroundStyle(color)
    }
}
