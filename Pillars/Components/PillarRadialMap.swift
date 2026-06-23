import SwiftUI

/// A distinctive radial map of all eight pillars — a custom radar/spider chart drawn with
/// pure SwiftUI paths. Faint octagonal grid, gold data shape, and a colored node per
/// pillar. Used compactly on the dashboard and at full size (with labels) on the Map.
struct PillarRadialMap: View {
    /// Each pillar's 1–5 score.
    let scores: [PillarType: Int]
    var showLabels: Bool = true
    var maxScore: Int = 5

    private let pillars = PillarType.allCases

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            // Leave room for labels when shown.
            let radius = side / 2 * (showLabels ? 0.66 : 0.86)

            ZStack {
                // Grid rings (octagons).
                ForEach(1...4, id: \.self) { ring in
                    ringPath(scale: CGFloat(ring) / 4, center: center, radius: radius)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                }

                // Axes.
                ForEach(Array(pillars.enumerated()), id: \.element) { index, _ in
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: vertex(index: index, value: Double(maxScore), center: center, radius: radius))
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }

                // Data shape — soft gold fill + crisp stroke.
                dataPath(center: center, radius: radius)
                    .fill(
                        RadialGradient(
                            colors: [PillarsColors.gold.opacity(0.30), PillarsColors.gold.opacity(0.05)],
                            center: .center, startRadius: 0, endRadius: radius
                        )
                    )
                dataPath(center: center, radius: radius)
                    .stroke(PillarsColors.gold.opacity(0.75), style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))

                // Pillar nodes.
                ForEach(Array(pillars.enumerated()), id: \.element) { index, pillar in
                    let value = Double(scores[pillar] ?? 0)
                    Circle()
                        .fill(pillar.color)
                        .frame(width: 9, height: 9)
                        .shadow(color: pillar.color.opacity(0.7), radius: 4)
                        .position(vertex(index: index, value: value, center: center, radius: radius))
                }

                // Axis labels.
                if showLabels {
                    ForEach(Array(pillars.enumerated()), id: \.element) { index, pillar in
                        PillarAxisLabel(pillar: pillar, score: scores[pillar] ?? 0)
                            .position(vertex(index: index, value: Double(maxScore) * 1.34, center: center, radius: radius))
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: scores)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: Geometry

    /// Position for a pillar's vertex at a given value (0...maxScore), starting at the top
    /// and proceeding clockwise.
    private func vertex(index: Int, value: Double, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = (Double(index) / Double(pillars.count)) * 2 * .pi - .pi / 2
        let r = radius * CGFloat(value / Double(maxScore))
        return CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
    }

    private func ringPath(scale: CGFloat, center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            for index in 0..<pillars.count {
                let point = vertex(index: index, value: Double(maxScore) * Double(scale), center: center, radius: radius)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }

    private func dataPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            for (index, pillar) in pillars.enumerated() {
                // Floor the value slightly so the shape never collapses to a point.
                let value = max(Double(scores[pillar] ?? 0), 0.35)
                let point = vertex(index: index, value: value, center: center, radius: radius)
                if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.closeSubpath()
        }
    }
}

/// Compact label placed at the end of a radar axis.
private struct PillarAxisLabel: View {
    let pillar: PillarType
    let score: Int

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: pillar.icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(pillar.color)
            Text(pillar.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(PillarsColors.secondaryText)
            Text("\(score)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(PillarsColors.primaryText)
        }
        .frame(width: 64)
        .multilineTextAlignment(.center)
        .fixedSize()
    }
}
