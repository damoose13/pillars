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

            RadialGradient(
                colors: [PillarsColors.gold.opacity(0.11), .clear],
                center: .init(x: 0.5, y: -0.05),
                startRadius: 8,
                endRadius: 560
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, .black.opacity(0.32)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

extension View {
    /// Places the standard Pillars atmospheric background behind the view.
    func pillarsBackground() -> some View {
        self.background(PillarsBackground())
    }
}
