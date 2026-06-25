import SwiftUI

/// Devices — Pillars in the physical world. Shows the Pillars Band's pairing state and latest
/// read (resting HR, HRV, sleep, readiness), and the camera-less Pillars HUD as the next step.
/// The hardware promise runs through it: *it senses you, it does not record the world.*
struct DevicesView: View {
    @Environment(BandManager.self) private var band

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                header
                bandCard
                hudCard
                privacyFooter
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PillarsSpacing.screenH)
            .padding(.top, PillarsSpacing.m)
            .padding(.bottom, PillarsSpacing.xxl)
        }
        .scrollIndicators(.hidden)
        .pillarsBackground()
        .navigationTitle("Devices")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Devices")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
            Text("Pillars in the physical world. The band senses you to support Body and Recover — it never records around you.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Band

    @ViewBuilder private var bandCard: some View {
        PillarGlassCard(highlight: band.isPaired) {
            VStack(alignment: .leading, spacing: PillarsSpacing.l) {
                HStack(spacing: PillarsSpacing.s) {
                    Image(systemName: "applewatch.side.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(PillarsColors.gold)
                    Text("Pillars Band")
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Spacer(minLength: 0)
                    statusChip
                }

                if band.isPaired {
                    pairedBody
                } else {
                    unpairedBody
                }
            }
        }
    }

    private var statusChip: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(band.isPaired ? PillarsColors.positive : PillarsColors.tertiaryText)
                .frame(width: 7, height: 7)
            Text(band.isPaired ? "Connected" : "Not paired")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(band.isPaired ? PillarsColors.positive : PillarsColors.tertiaryText)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill((band.isPaired ? PillarsColors.positive : PillarsColors.tertiaryText).opacity(0.12)))
    }

    @ViewBuilder private var pairedBody: some View {
        if let reading = band.readiness {
            readinessHero(reading)
        }
        if let signals = band.latest {
            metricsGrid(signals)
        }
        HStack(spacing: PillarsSpacing.m) {
            Button { Task { await band.sync() } } label: {
                Label(band.isSyncing ? "Syncing…" : "Sync", systemImage: "arrow.triangle.2.circlepath")
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.white.opacity(0.06)))
                    .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(band.isSyncing)

            Button { band.unpair() } label: {
                Text("Forget")
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(PillarsColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.white.opacity(0.04)))
                    .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var unpairedBody: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            Text("Pair the band to read resting heart rate, heart-rate variability, sleep, and a daily readiness score — feeding the Recover and Body pillars.")
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
            Button { Task { await band.pair() } } label: {
                HStack(spacing: PillarsSpacing.xs) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text(band.isSyncing ? "Pairing…" : "Pair Pillars Band")
                }
                .font(PillarsTypography.headline)
                .foregroundStyle(PillarsColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Capsule().fill(PillarsColors.gold))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(band.isSyncing)
        }
    }

    private func readinessHero(_ reading: ReadinessReading) -> some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Text("Readiness")
                .pillarsOverline()
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(reading.score)")
                    .font(PillarsFont.serif(40, .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                Text(reading.band.label)
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(color(for: reading.band))
            }
            Text(reading.detail)
                .font(PillarsTypography.callout)
                .foregroundStyle(PillarsColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(PillarsSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: PillarsRadius.small).fill(color(for: reading.band).opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: PillarsRadius.small).strokeBorder(color(for: reading.band).opacity(0.25), lineWidth: 1))
    }

    private func metricsGrid(_ s: BandSignals) -> some View {
        let columns = [GridItem(.flexible(), spacing: PillarsSpacing.s), GridItem(.flexible(), spacing: PillarsSpacing.s)]
        return LazyVGrid(columns: columns, spacing: PillarsSpacing.s) {
            if let rhr = s.restingHeartRate {
                MetricTile(icon: "heart.fill", label: "Resting HR", value: "\(rhr)", unit: "bpm")
            }
            if let hrv = s.heartRateVariability {
                MetricTile(icon: "waveform.path.ecg", label: "HRV", value: "\(hrv)", unit: "ms")
            }
            if let hours = s.sleepHours {
                MetricTile(icon: "moon.stars.fill", label: "Sleep", value: String(format: "%.1f", hours), unit: "hrs")
            }
            if let score = s.sleepScore {
                MetricTile(icon: "bed.double.fill", label: "Sleep score", value: "\(score)", unit: "/100")
            }
            if let rr = s.respiratoryRate {
                MetricTile(icon: "lungs.fill", label: "Respiration", value: String(format: "%.1f", rr), unit: "br/min")
            }
        }
    }

    private func color(for band: ReadinessBand) -> Color {
        switch band {
        case .ready:    return PillarsColors.positive
        case .steady:   return PillarsColors.goldSoft
        case .easeIn:   return PillarsColors.gold
        case .holdBack: return PillarsColors.secondaryText
        }
    }

    // MARK: HUD

    private var hudCard: some View {
        PillarGlassCard {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                HStack(spacing: PillarsSpacing.s) {
                    Image(systemName: "eyeglasses")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(PillarsColors.secondaryText)
                    Text("Pillars HUD")
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                    Spacer(minLength: 0)
                    Text("Coming")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                }
                Text("A camera-less, mic-less heads-up display: current set, reps, rest timer, heart rate — peripheral when you need it, invisible when you don't. It guides training without recording anyone.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var privacyFooter: some View {
        Text("Your device senses you. It does not record the world. Band data stays on this device and feeds only your own Pillar Web.")
            .font(PillarsTypography.caption)
            .foregroundStyle(PillarsColors.tertiaryText)
            .lineSpacing(1.5)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, PillarsSpacing.xs)
    }
}

/// One physiological metric, glass-tiled.
private struct MetricTile: View {
    let icon: String
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PillarsColors.gold)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(PillarsFont.serif(24, .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                Text(unit)
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
            }
            Text(label)
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PillarsSpacing.m)
        .background(RoundedRectangle(cornerRadius: PillarsRadius.small).fill(Color.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: PillarsRadius.small).strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
    }
}

#if DEBUG
#Preview {
    NavigationStack { DevicesView() }
        .environment(BandManager.previewPaired())
        .preferredColorScheme(.dark)
}
#endif
