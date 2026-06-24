import SwiftUI

/// The first half-second of the app: the Pillar Web draws itself in gold, the wordmark
/// settles beneath it, and the whole thing fades into the app. A quiet brand moment.
struct LaunchView: View {
    var onFinished: () -> Void = {}

    @State private var draw: CGFloat = 0
    @State private var glow = false
    @State private var wordmark = false

    /// A calm, balanced sample shape — decoration only.
    private let sample: [CGFloat] = [0.95, 0.62, 0.86, 0.52, 0.80, 0.46, 0.90, 0.66]

    var body: some View {
        ZStack {
            PillarsBackground()

            VStack(spacing: PillarsSpacing.xl) {
                webMark
                    .frame(width: 224, height: 224)

                VStack(spacing: PillarsSpacing.s) {
                    Text("Pillars")
                        .font(PillarsFont.serif(44, .semibold))
                        .foregroundStyle(PillarsColors.primaryText)
                        .tracking(0.5)
                    Text("The quiet operating system for a steady life.")
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(wordmark ? 1 : 0)
                .offset(y: wordmark ? 0 : 12)
            }
            .padding(.horizontal, 48)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1)) { draw = 1 }
            withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) { glow = true }
            withAnimation(.smooth(duration: 0.7).delay(0.55)) { wordmark = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.85) { onFinished() }
        }
    }

    private var webMark: some View {
        GeometryReader { proxy in
            let c = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let r = min(proxy.size.width, proxy.size.height) / 2 * 0.86
            ZStack {
                ForEach(1...3, id: \.self) { ring in
                    PolygonShape(points: octagon(center: c, radius: r * CGFloat(ring) / 3,
                                                 values: Array(repeating: 1, count: 8)))
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                }
                PolygonShape(points: octagon(center: c, radius: r, values: sample))
                    .fill(RadialGradient(colors: [PillarsColors.gold.opacity(0.18), .clear],
                                         center: .center, startRadius: 0, endRadius: r))
                    .opacity(draw)
                PolygonShape(points: octagon(center: c, radius: r, values: sample))
                    .trim(from: 0, to: draw)
                    .stroke(LinearGradient(colors: [PillarsColors.goldSoft, PillarsColors.gold],
                                           startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 2.6, lineJoin: .round))
                    .shadow(color: PillarsColors.gold.opacity(glow ? 0.55 : 0.22), radius: glow ? 18 : 8)
                Circle()
                    .fill(PillarsColors.goldSoft)
                    .frame(width: 11, height: 11)
                    .position(c)
                    .opacity(draw)
            }
        }
    }

    private func octagon(center: CGPoint, radius: CGFloat, values: [CGFloat]) -> [CGPoint] {
        values.indices.map { i in
            let angle = (Double(i) / Double(values.count)) * 2 * .pi - .pi / 2
            let rr = Double(radius) * Double(values[i])
            return CGPoint(x: center.x + CGFloat(cos(angle) * rr), y: center.y + CGFloat(sin(angle) * rr))
        }
    }
}

#if DEBUG
#Preview {
    LaunchView().preferredColorScheme(.dark)
}
#endif
