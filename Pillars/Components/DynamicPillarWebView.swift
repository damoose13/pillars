import SwiftUI

/// The Pillar Web — the central, interactive object of Pillars. An octagonal radar that
/// shows the shape of the day, reveals the weak point (it softly pulses), and lets the user
/// tap a pillar to select it. Reused as Today's hero, the Map, weekly/mini variants, and a
/// privacy-safe blurred trend for Circles.
struct DynamicPillarWebView: View {
    let scores: [PillarWebScore]
    var mode: PillarWebMode = .standard
    var weakestPillar: PillarType? = nil
    var strongestPillar: PillarType? = nil
    @Binding var selectedPillar: PillarType?

    @State private var pulse = false

    init(scores: [PillarWebScore], mode: PillarWebMode = .standard,
         weakestPillar: PillarType? = nil, strongestPillar: PillarType? = nil,
         selectedPillar: Binding<PillarType?> = .constant(nil)) {
        self.scores = scores
        self.mode = mode
        self.weakestPillar = weakestPillar
        self.strongestPillar = strongestPillar
        self._selectedPillar = selectedPillar
    }

    private var ordered: [PillarWebScore] {
        PillarType.allCases.compactMap { pillar in scores.first { $0.pillar == pillar } }
    }

    private var systemScore: Int {
        guard !ordered.isEmpty else { return 0 }
        let total = ordered.map(\.score).reduce(0, +)
        return Int((Double(total) / Double(ordered.count) / 5.0 * 100.0).rounded())
    }

    private var interactive: Bool { mode == .hero || mode == .standard }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = side * radiusMultiplier

            ZStack {
                grid(center: center, radius: radius)
                fill(center: center, radius: radius)
                stroke(center: center, radius: radius)
                points(center: center, radius: radius)
                if mode != .mini && mode != .background && mode != .blurred {
                    labels(center: center, radius: radius)
                }
                centerContent
            }
            .blur(radius: mode == .blurred ? 9 : 0)
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .onAppear {
            guard mode != .background, mode != .blurred else { return }
            withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    /// Fraction of the *min side* used for the data ring. Kept small enough that external
    /// labels (placed at `radius + labelOffset`) stay inside the frame.
    private var radiusMultiplier: CGFloat {
        switch mode {
        case .background: return 0.44
        case .mini: return 0.42
        case .standard: return 0.35
        case .hero: return 0.34
        case .weekly: return 0.35
        case .blurred: return 0.40
        }
    }

    private var labelOffset: CGFloat {
        switch mode {
        case .hero: return 32
        case .standard: return 28
        case .weekly: return 26
        default: return 0
        }
    }

    // MARK: Layers

    private func grid(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(1...5, id: \.self) { level in
                PolygonShape(points: polygon(center: center, radius: radius * CGFloat(level) / 5,
                                             values: Array(repeating: 1, count: ordered.count)))
                    .stroke(Color.white.opacity(mode == .background ? 0.04 : 0.07), lineWidth: 1)
            }
            ForEach(ordered.indices, id: \.self) { index in
                Path { p in
                    p.move(to: center)
                    p.addLine(to: vertex(index: index, total: ordered.count, center: center, radius: radius))
                }
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
        }
    }

    private func fill(center: CGPoint, radius: CGFloat) -> some View {
        PolygonShape(points: polygon(center: center, radius: radius, values: ordered.map(\.normalized)))
            .fill(RadialGradient(
                colors: [PillarsColors.gold.opacity(mode == .background ? 0.08 : 0.24),
                         PillarsColors.gold.opacity(mode == .background ? 0.02 : 0.05)],
                center: .center, startRadius: 0, endRadius: radius))
    }

    private func stroke(center: CGPoint, radius: CGFloat) -> some View {
        PolygonShape(points: polygon(center: center, radius: radius, values: ordered.map(\.normalized)))
            .stroke(PillarsColors.gold.opacity(mode == .background ? 0.28 : 0.78),
                    style: StrokeStyle(lineWidth: mode == .hero ? 2.2 : 1.6, lineJoin: .round))
            .shadow(color: PillarsColors.gold.opacity(mode == .hero ? 0.30 : 0.12), radius: 10)
    }

    private func points(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(ordered.indices, id: \.self) { index in
                let item = ordered[index]
                let position = vertex(index: index, total: ordered.count, center: center,
                                      radius: radius * max(item.normalized, 0.08))
                let isSelected = selectedPillar == item.pillar
                let isWeakest = weakestPillar == item.pillar
                let isStrongest = strongestPillar == item.pillar

                Circle()
                    .fill(item.pillar.color)
                    .frame(width: isSelected ? 15 : 10, height: isSelected ? 15 : 10)
                    .overlay(Circle().stroke(Color.white.opacity(isSelected ? 0.55 : 0.12), lineWidth: 1))
                    .shadow(color: item.pillar.color.opacity(isSelected || isWeakest ? 0.65 : 0.20),
                            radius: isSelected ? 14 : (isWeakest ? (pulse ? 16 : 6) : (isStrongest ? 8 : 3)))
                    .scaleEffect(isWeakest && pulse && !isSelected ? 1.14 : 1.0)
                    .frame(width: 44, height: 44)          // accessible tap target
                    .contentShape(Rectangle())
                    .position(position)
                    .onTapGesture {
                        guard interactive else { return }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) { selectedPillar = item.pillar }
                    }
                    .accessibilityLabel("\(item.pillar.displayName), \(item.state.displayName)")
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    private func labels(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(ordered.indices, id: \.self) { index in
                let item = ordered[index]
                let position = vertex(index: index, total: ordered.count, center: center, radius: radius + labelOffset)
                VStack(spacing: 1) {
                    Image(systemName: item.pillar.icon)
                        .font(.system(size: mode == .hero ? 13 : 11, weight: .semibold))
                        .foregroundStyle(item.pillar.color)
                    Text(item.pillar.displayName)
                        .font(.system(size: mode == .hero ? 11 : 10, weight: .semibold))
                        .foregroundStyle(selectedPillar == item.pillar ? PillarsColors.primaryText : PillarsColors.secondaryText)
                }
                .frame(width: 70)
                .multilineTextAlignment(.center)
                .position(position)
                .onTapGesture {
                    guard interactive else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) { selectedPillar = item.pillar }
                }
            }
        }
    }

    @ViewBuilder private var centerContent: some View {
        if let selected = selectedPillar, let item = ordered.first(where: { $0.pillar == selected }), interactive {
            VStack(spacing: 3) {
                Text(item.pillar.displayName)
                    .font(PillarsFont.serif(mode == .hero ? 24 : 19, .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                Text(item.state.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(item.state.color)
            }
        } else if mode == .hero || mode == .standard || mode == .weekly {
            VStack(spacing: 2) {
                Text("\(systemScore)")
                    .font(PillarsFont.serif(mode == .hero ? 40 : 32, .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                    .monospacedDigit()
                Text("Foundation")
                    .pillarsOverline()
            }
        }
    }

    private var accessibilitySummary: String {
        let weak = weakestPillar?.displayName ?? "none"
        let strong = strongestPillar?.displayName ?? "none"
        return "Pillar web. Foundation score \(systemScore). \(weak) is asking for support; \(strong) is holding firm."
    }

    // MARK: Geometry

    private func vertex(index: Int, total: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = (Double(index) / Double(total)) * 2 * .pi - .pi / 2
        let r = Double(radius)
        return CGPoint(x: center.x + CGFloat(cos(angle) * r), y: center.y + CGFloat(sin(angle) * r))
    }

    private func polygon(center: CGPoint, radius: CGFloat, values: [CGFloat]) -> [CGPoint] {
        values.indices.map { index in
            vertex(index: index, total: values.count, center: center, radius: radius * values[index])
        }
    }
}
