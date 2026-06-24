import SwiftUI

/// Spacing scale — generous by default. Premium UIs breathe.
enum PillarsSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 36
    static let xxl: CGFloat = 56
    /// Standard horizontal screen inset.
    static let screenH: CGFloat = 22
}

/// Corner radii.
enum PillarsRadius {
    static let card: CGFloat = 28
    static let inner: CGFloat = 18
    static let small: CGFloat = 12
    static let pill: CGFloat = 999
}

/// The app's atmospheric background: warm off-black with a single, restrained gold glow
/// at the top and a quiet deepening toward the bottom. Subtle — never a cheesy gradient.
struct PillarsBackground: View {
    var body: some View {
        ZStack {
            PillarsColors.background
                .ignoresSafeArea()

            // Primary warm glow, top-centre.
            RadialGradient(
                colors: [PillarsColors.gold.opacity(0.13), .clear],
                center: .init(x: 0.5, y: -0.04),
                startRadius: 8,
                endRadius: 600
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()

            // A second, fainter glow offset left for asymmetric, lived-in light.
            RadialGradient(
                colors: [PillarsColors.goldSoft.opacity(0.05), .clear],
                center: .init(x: 0.12, y: 0.22),
                startRadius: 0,
                endRadius: 360
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()

            // Cool deepening in the lower-right gives the ground dimensionality.
            RadialGradient(
                colors: [Color(red: 0.04, green: 0.05, blue: 0.08).opacity(0.55), .clear],
                center: .init(x: 0.92, y: 1.02),
                startRadius: 0,
                endRadius: 480
            )
            .ignoresSafeArea()

            // Fine film grain keeps the off-black from looking flat or banded.
            Image("Grain")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
                .opacity(0.035)
                .blendMode(.overlay)
                .allowsHitTesting(false)

            // Bottom darkening anchors content.
            LinearGradient(
                colors: [.clear, .black.opacity(0.34)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Soft vignette draws the eye inward.
            RadialGradient(
                colors: [.clear, .black.opacity(0.26)],
                center: .center,
                startRadius: 260,
                endRadius: 720
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

extension View {
    /// Places the standard Pillars atmospheric background behind the view.
    func pillarsBackground() -> some View {
        self.background(PillarsBackground())
    }
}
