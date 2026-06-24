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
                    .overlay {
                        // Soft top-lit sheen inside the glass.
                        shape.fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.06), .clear],
                                startPoint: .top, endPoint: .center
                            )
                        )
                    }
                    .overlay {
                        // Highlighted cards carry a faint warm glow from the top edge.
                        if highlight {
                            shape.fill(
                                RadialGradient(
                                    colors: [PillarsColors.gold.opacity(0.10), .clear],
                                    center: .top, startRadius: 0, endRadius: 260
                                )
                            )
                        }
                    }
            }
            .overlay {
                // A faint top-edge sheen makes the glass feel lit from above.
                shape.strokeBorder(
                    LinearGradient(
                        colors: [
                            (highlight ? PillarsColors.gold.opacity(0.45) : Color.white.opacity(0.20)),
                            PillarsColors.cardBorder
                        ],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            .clipShape(shape)
            .shadow(color: .black.opacity(0.40), radius: 28, x: 0, y: 18)
            .shadow(color: .black.opacity(0.16), radius: 3, x: 0, y: 2)
    }
}
