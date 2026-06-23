import SwiftUI

/// The felt quality of a restoration — how it's meant to land, not just what it does. Used
/// to frame moves in human, non-clinical language.
enum EmotionalTone: String, Codable, CaseIterable, Hashable {
    case grounding
    case tender
    case energizing
    case clarifying
    case connecting
    case reflective
    case settling

    var label: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    /// A muted accent for the tone — subtle, never loud.
    var color: Color {
        switch self {
        case .grounding:  return Color(red: 0.60, green: 0.64, blue: 0.50)
        case .tender:     return Color(red: 0.82, green: 0.55, blue: 0.57)
        case .energizing: return Color(red: 0.84, green: 0.55, blue: 0.42)
        case .clarifying: return Color(red: 0.52, green: 0.62, blue: 0.78)
        case .connecting: return Color(red: 0.80, green: 0.62, blue: 0.42)
        case .reflective: return Color(red: 0.62, green: 0.54, blue: 0.78)
        case .settling:   return Color(red: 0.46, green: 0.60, blue: 0.66)
        }
    }
}
