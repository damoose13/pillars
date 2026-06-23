import SwiftUI

/// The core surface of the app: a frosted glass card with a quiet hairline border and a
/// soft drop shadow. Everything that holds content sits in one of these.
///
/// ```swift
/// PillarGlassCard {
///     Text("Today's Foundation")
/// }
/// ```
struct PillarGlassCard<Content: View>: View {
    var padding: CGFloat
    var cornerRadius: CGFloat
    var highlight: Bool
    var content: Content

    init(
        padding: CGFloat = PillarsSpacing.l,
        cornerRadius: CGFloat = PillarsRadius.card,
        highlight: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.highlight = highlight
        self.content = content()
    }

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: cornerRadius, style: .continuous) }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                shape
                    .fill(.ultraThinMaterial)
                    .overlay { shape.fill(PillarsColors.card) }
            }
            .overlay {
                // A faint top-edge sheen makes the glass feel lit from above.
                shape.strokeBorder(
                    LinearGradient(
                        colors: [
                            (highlight ? PillarsColors.gold.opacity(0.45) : Color.white.opacity(0.18)),
                            PillarsColors.cardBorder
                        ],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            .clipShape(shape)
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 16)
    }
}
