import SwiftUI

/// The Pillars palette.
///
/// Warm off-black ground, soft ivory text, a single restrained gold accent, and a set
/// of muted pillar colors. Nothing neon, nothing childish. Tuned for a dark, premium
/// "operating system" feel rather than a bright wellness app.
enum PillarsColors {

    // MARK: Surfaces
    /// Warm near-black background.
    static let background = Color(red: 0.05, green: 0.045, blue: 0.06)
    /// A slightly lifted surface for layering behind glass.
    static let surface = Color(red: 0.09, green: 0.085, blue: 0.10)
    /// Glass card fill (sits on top of a material blur).
    static let card = Color.white.opacity(0.06)
    /// Hairline border for glass cards.
    static let cardBorder = Color.white.opacity(0.10)
    /// A stronger hairline for emphasis.
    static let hairline = Color.white.opacity(0.14)

    // MARK: Text
    /// Primary ivory text.
    static let primaryText = Color(red: 0.94, green: 0.91, blue: 0.84)
    /// Muted secondary text.
    static let secondaryText = Color(red: 0.68, green: 0.65, blue: 0.58)
    /// Faint tertiary text for overlines and footnotes.
    static let tertiaryText = Color(red: 0.50, green: 0.48, blue: 0.44)

    // MARK: Accent
    /// The single brand accent — a quiet, warm gold.
    static let gold = Color(red: 0.78, green: 0.62, blue: 0.34)
    static let goldSoft = Color(red: 0.82, green: 0.69, blue: 0.46)

    // MARK: Signal (used sparingly for trends — never for "good/bad" judgement)
    static let positive = Color(red: 0.46, green: 0.66, blue: 0.53)
    static let caution = Color(red: 0.80, green: 0.49, blue: 0.45)

    // MARK: Circle member avatars — muted, distinct from the pillar palette.
    static let memberPalette: [Color] = [
        Color(red: 0.80, green: 0.55, blue: 0.45),
        Color(red: 0.55, green: 0.62, blue: 0.78),
        Color(red: 0.58, green: 0.70, blue: 0.55),
        Color(red: 0.74, green: 0.58, blue: 0.72),
        Color(red: 0.78, green: 0.68, blue: 0.42),
        Color(red: 0.50, green: 0.68, blue: 0.66)
    ]
}
