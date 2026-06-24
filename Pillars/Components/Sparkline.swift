import SwiftUI

/// A calm line trend for a single pillar over time: a smooth gold-tinted line with a soft
/// area fill and a marker on the latest point. Premium and continuous — never a bar chart.
struct Sparkline: View {
    /// Scores in chronological order (oldest → newest), each 1–5.
    let values: [Int]
    var color: Color
    var lineWidth: CGFloat = 2.4

    private var points: [CGFloat] {
        values.map { CGFloat(max(1, min(5, $0))) }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let positions = coordinates(in: CGSize(width: w, height: h))

            ZStack {
                // baseline grid (min / mid / max)
                ForEach([0.0, 0.5, 1.0], id: \.self) { f in
                    Path { p in
                        let y = h - CGFloat(f) * h
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: w, y: y))
                    }
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                }

                if positions.count > 1 {
                    // soft area fill
                    areaPath(positions, height: h)
                        .fill(LinearGradient(
                            colors: [color.opacity(0.22), color.opacity(0.0)],
                            startPoint: .top, endPoint: .bottom))

                    // the line
                    linePath(positions)
                        .stroke(
                            LinearGradient(colors: [color.opacity(0.95), color],
                                           startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .shadow(color: color.opacity(0.35), radius: 6)

                    // latest marker
                    if let last = positions.last {
                        Circle()
                            .fill(color)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                            .position(last)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recent trend")
        .accessibilityValue(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        guard let first = values.first, let last = values.last, values.count > 1 else {
            return "Not enough history yet."
        }
        let direction = last > first ? "rising" : (last < first ? "easing" : "steady")
        return "\(direction), now \(last) of 5 over the last \(values.count) check-ins."
    }

    private func coordinates(in size: CGSize) -> [CGPoint] {
        guard !points.isEmpty else { return [] }
        let stepX = points.count > 1 ? size.width / CGFloat(points.count - 1) : 0
        return points.indices.map { i in
            let norm = (points[i] - 1) / 4            // 1...5 → 0...1
            let y = size.height - norm * size.height
            return CGPoint(x: CGFloat(i) * stepX, y: max(4, min(size.height - 4, y)))
        }
    }

    private func linePath(_ pts: [CGPoint]) -> Path {
        Path { path in
            guard let first = pts.first else { return }
            path.move(to: first)
            for p in pts.dropFirst() { path.addLine(to: p) }
        }
    }

    private func areaPath(_ pts: [CGPoint], height: CGFloat) -> Path {
        Path { path in
            guard let first = pts.first, let last = pts.last else { return }
            path.move(to: CGPoint(x: first.x, y: height))
            path.addLine(to: first)
            for p in pts.dropFirst() { path.addLine(to: p) }
            path.addLine(to: CGPoint(x: last.x, y: height))
            path.closeSubpath()
        }
    }
}
