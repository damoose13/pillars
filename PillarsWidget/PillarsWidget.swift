import WidgetKit
import SwiftUI

// The widget runs in its own process and can't reach the app's SwiftData store without an
// App Group (which needs signing), so v1 is a calm, self-contained check-in nudge: the brand
// Pillar Web on the warm ground, inviting a tap into the app. Live scores can follow once an
// App Group is configured.

private enum WidgetColors {
    static let background = Color(red: 0.05, green: 0.045, blue: 0.06)
    static let ivory = Color(red: 0.94, green: 0.91, blue: 0.84)
    static let sub = Color(red: 0.68, green: 0.65, blue: 0.58)
    static let gold = Color(red: 0.78, green: 0.62, blue: 0.34)
    static let goldSoft = Color(red: 0.82, green: 0.69, blue: 0.46)
}

/// A closed polygon through points — the web's grid and data shapes.
private struct WidgetPolygon: Shape {
    let points: [CGPoint]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for p in points.dropFirst() { path.addLine(to: p) }
        path.closeSubpath()
        return path
    }
}

/// A small, decorative Pillar Web for the widget.
private struct WidgetWeb: View {
    var lineWidth: CGFloat = 2
    private let sample: [CGFloat] = [0.95, 0.62, 0.86, 0.52, 0.80, 0.46, 0.90, 0.66]

    var body: some View {
        GeometryReader { proxy in
            let c = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let r = min(proxy.size.width, proxy.size.height) / 2 * 0.92
            ZStack {
                ForEach(1...3, id: \.self) { ring in
                    WidgetPolygon(points: octagon(center: c, radius: r * CGFloat(ring) / 3, values: ones))
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                }
                WidgetPolygon(points: octagon(center: c, radius: r, values: sample))
                    .fill(RadialGradient(colors: [WidgetColors.gold.opacity(0.22), .clear],
                                         center: .center, startRadius: 0, endRadius: r))
                WidgetPolygon(points: octagon(center: c, radius: r, values: sample))
                    .stroke(LinearGradient(colors: [WidgetColors.goldSoft, WidgetColors.gold],
                                           startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                Circle().fill(WidgetColors.goldSoft).frame(width: 6, height: 6).position(c)
            }
        }
    }

    private var ones: [CGFloat] { Array(repeating: 1, count: 8) }

    private func octagon(center: CGPoint, radius: CGFloat, values: [CGFloat]) -> [CGPoint] {
        values.indices.map { i in
            let a = (Double(i) / Double(values.count)) * 2 * .pi - .pi / 2
            let rr = Double(radius) * Double(values[i])
            return CGPoint(x: center.x + CGFloat(cos(a) * rr), y: center.y + CGFloat(sin(a) * rr))
        }
    }
}

private struct PillarsEntry: TimelineEntry {
    let date: Date
}

private struct PillarsProvider: TimelineProvider {
    func placeholder(in context: Context) -> PillarsEntry { PillarsEntry(date: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (PillarsEntry) -> Void) {
        completion(PillarsEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PillarsEntry>) -> Void) {
        // A single static entry — the nudge never goes stale.
        completion(Timeline(entries: [PillarsEntry(date: Date())], policy: .never))
    }
}

private struct PillarsWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: PillarsEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(WidgetColors.background)
            RadialGradient(colors: [WidgetColors.gold.opacity(0.14), .clear],
                           center: .top, startRadius: 0, endRadius: 180)

            if family == .systemSmall {
                VStack(spacing: 8) {
                    WidgetWeb().frame(height: 78)
                    Text("How are your\npillars today?")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundStyle(WidgetColors.ivory)
                        .multilineTextAlignment(.center)
                        .lineSpacing(1)
                }
                .padding(12)
            } else {
                HStack(spacing: 16) {
                    WidgetWeb().frame(width: 96, height: 96)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PILLARS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(WidgetColors.gold)
                        Text("How are your pillars today?")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(WidgetColors.ivory)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("A quiet minute to check in.")
                            .font(.system(size: 12))
                            .foregroundStyle(WidgetColors.sub)
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
            }
        }
    }
}

struct PillarsWidget: Widget {
    let kind = "PillarsCheckInWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PillarsProvider()) { entry in
            PillarsWidgetView(entry: entry)
                .containerBackground(WidgetColors.background, for: .widget)
        }
        .configurationDisplayName("Pillars")
        .description("A calm nudge to check in across your eight pillars.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct PillarsWidgetBundle: WidgetBundle {
    var body: some Widget {
        PillarsWidget()
    }
}
