import Foundation
import SwiftData

/// A trusted Circle.
///
/// **Foundation only.** The Circle feature layer (Circle Pulse, shared wins, privacy
/// rules) is deliberately deferred to a later version — there is no Circle UI in v0.1.
/// This model exists so the local schema is ready and stable when that work begins.
///
/// > Note: Named `CircleGroup` rather than `Circle` to avoid colliding with SwiftUI's
/// > `Circle` shape, which the design system uses heavily.
@Model
final class CircleGroup {
    var name: String
    var createdAt: Date
    /// Stored as a string for forward-compatibility, e.g. "privateByDefault".
    var privacyMode: String

    init(
        name: String,
        createdAt: Date = .now,
        privacyMode: String = "privateByDefault"
    ) {
        self.name = name
        self.createdAt = createdAt
        self.privacyMode = privacyMode
    }
}
