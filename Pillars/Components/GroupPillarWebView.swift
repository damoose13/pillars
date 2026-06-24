import SwiftUI

/// The Group Web — a Circle's aggregate shape, rendered deliberately *softer* than the
/// personal web: blurred, haloed in the group's morale color, and non-selectable. You can
/// feel the shape of the Circle without ever reading an individual out of it.
///
/// This is intentionally distinct from the clear, tappable personal web on Today — the blur
/// and the bloom are the visual promise that nothing here is anyone's private number.
struct GroupPillarWebView: View {
    let scores: [PillarWebScore]
    var morale: MoraleState = .steady

    var body: some View {
        ZStack {
            // Morale halo — a soft radial bloom whose warmth tracks the group's morale.
            Circle()
                .fill(RadialGradient(
                    colors: [morale.color.opacity(morale.glow), .clear],
                    center: .center, startRadius: 0, endRadius: 150))
                .blur(radius: 26)

            DynamicPillarWebView(scores: scores, mode: .blurred)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("A soft, blurred picture of the Circle's overall shape. No individual scores, no names, no numbers.")
    }
}

#if DEBUG
#Preview {
    GroupPillarWebView(
        scores: PillarType.allCases.map { PillarWebScore(pillar: $0, score: [2, 3, 4, 3, 3, 2, 4, 3][PillarType.allCases.firstIndex(of: $0)!]) },
        morale: .steady
    )
    .frame(height: 220)
    .padding()
    .pillarsBackground()
    .preferredColorScheme(.dark)
}
#endif
