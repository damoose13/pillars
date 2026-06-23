import SwiftUI
import SwiftData

/// Settings & privacy. Pillar naming (rename Purpose), the privacy promise, and data
/// controls. Styled as glass sections to match the rest of the app rather than a stock form.
struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context

    @Query private var checkIns: [DailyCheckIn]

    @State private var showClearConfirm = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
        return "Version \(v)"
    }

    var body: some View {
        @Bindable var appState = appState

        ScrollView {
            VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                    Text("Settings")
                        .font(PillarsTypography.display)
                        .foregroundStyle(PillarsColors.primaryText)
                    Text("\(checkIns.count) check-in\(checkIns.count == 1 ? "" : "s") recorded, all on this device.")
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                }

                purposeSection(appState: appState)
                privacySection
                dataSection
                aboutSection
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PillarsSpacing.screenH)
            .padding(.top, PillarsSpacing.xl)
            .padding(.bottom, PillarsSpacing.xxl)
        }
        .scrollIndicators(.hidden)
        .pillarsBackground()
        .confirmationDialog(
            "Clear all check-ins and moves?",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("Clear everything", role: .destructive) { clearAllData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes your check-in history from this device and returns you to the welcome screen. It cannot be undone.")
        }
    }

    // MARK: Sections

    private func purposeSection(appState: AppState) -> some View {
        SettingsSection(title: "The eighth pillar", icon: "mountain.2.fill") {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("Name the Purpose pillar in a way that fits your life. This changes its label everywhere.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                // Quick suggestions.
                FlowChips(
                    options: PillarType.purposeAliasSuggestions,
                    isSelected: { isAliasSelected($0) },
                    onTap: { selectAlias($0) }
                )

                // Custom entry.
                TextField("Custom name", text: Binding(
                    get: { appState.purposeAlias },
                    set: { appState.purposeAlias = $0 }
                ))
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.primaryText)
                .tint(PillarsColors.gold)
                .padding(PillarsSpacing.s)
                .background(RoundedRectangle(cornerRadius: PillarsRadius.small).fill(Color.white.opacity(0.04)))
                .overlay(RoundedRectangle(cornerRadius: PillarsRadius.small).strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
            }
        }
    }

    private var privacySection: some View {
        SettingsSection(title: "Privacy", icon: "lock.fill") {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Private by design.")
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("Your check-ins, notes, and scores are stored only on this device. Nothing is uploaded, shared, or used to identify you. When Circles arrive, your individual scores will stay private there too — only signals you choose to share are ever shown.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var dataSection: some View {
        SettingsSection(title: "Your data", icon: "tray.full.fill") {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                Text("You're always in control of your history.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    HStack(spacing: PillarsSpacing.xs) {
                        Image(systemName: "trash")
                        Text("Clear all data")
                    }
                    .font(PillarsTypography.headline)
                    .foregroundStyle(PillarsColors.caution)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(PillarsColors.caution.opacity(0.10)))
                    .overlay(Capsule().strokeBorder(PillarsColors.caution.opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle.fill") {
            VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                Text("Pillars")
                    .font(PillarsFont.serif(20, .semibold))
                    .foregroundStyle(PillarsColors.primaryText)
                Text("A private wellness operating system. Not a tracker, not a clinic — a quiet way to notice what needs you, and restore it.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(appVersion)
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .padding(.top, PillarsSpacing.xs)
            }
        }
    }

    // MARK: Purpose alias helpers

    private func isAliasSelected(_ option: String) -> Bool {
        if option == "Purpose" { return appState.purposeAlias.isEmpty }
        return appState.purposeAlias.caseInsensitiveCompare(option) == .orderedSame
    }

    private func selectAlias(_ option: String) {
        appState.purposeAlias = (option == "Purpose") ? "" : option
    }

    // MARK: Data

    private func clearAllData() {
        try? context.delete(model: DailyCheckIn.self)
        try? context.delete(model: PillarAction.self)
        try? context.delete(model: SharedWin.self)
        try? context.delete(model: CircleGroup.self)
        try? context.save()
        appState.resetOnboarding()
    }
}

// MARK: - Building blocks

/// A titled glass section used throughout Settings.
private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.s) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(PillarsColors.gold)
            }
            .pillarsOverline()

            PillarGlassCard { content }
        }
    }
}

/// A simple wrapping row of selectable chips.
private struct FlowChips: View {
    let options: [String]
    let isSelected: (String) -> Bool
    let onTap: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button { onTap(option) } label: {
                    Text(option)
                        .font(PillarsTypography.callout.weight(.medium))
                        .foregroundStyle(isSelected(option) ? PillarsColors.background : PillarsColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(isSelected(option) ? PillarsColors.gold : Color.white.opacity(0.05))
                        )
                        .overlay(
                            Capsule().strokeBorder(isSelected(option) ? Color.clear : PillarsColors.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .environment(AppState())
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
