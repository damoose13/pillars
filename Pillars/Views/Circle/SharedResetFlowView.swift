import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

/// Turn a Circle Pulse suggestion into a real, shared moment: pick a reset, send a warm
/// invitation, show up, and record a voluntary shared win. Privacy-safe throughout — only
/// the message you send and the win you choose to share ever leave your device.
struct SharedResetFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    /// Optionally pre-select a ritual (e.g. from a Pulse suggestion).
    var preselected: Ritual? = nil

    @State private var step: Step = .choose
    @State private var ritual: Ritual?
    @State private var copied = false

    enum Step { case choose, invite, showUp, done }

    private var resets: [Ritual] { RitualLibrary.sharedResets }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    progress
                    switch step {
                    case .choose: chooseStep
                    case .invite: inviteStep
                    case .showUp: showUpStep
                    case .done: doneStep
                    }
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Shared reset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(step == .done ? "Done" : "Cancel") { dismiss() }
                        .foregroundStyle(step == .done ? PillarsColors.gold : PillarsColors.secondaryText)
                }
            }
            .onAppear {
                if let preselected { ritual = preselected; step = .invite }
            }
        }
    }

    // MARK: Progress

    private var progress: some View {
        let stages: [Step] = [.choose, .invite, .showUp]
        return HStack(spacing: 6) {
            ForEach(0..<stages.count, id: \.self) { i in
                Capsule()
                    .fill(stageIndex >= i ? PillarsColors.gold : Color.white.opacity(0.10))
                    .frame(height: 4)
            }
        }
    }

    private var stageIndex: Int {
        switch step { case .choose: return 0; case .invite: return 1; case .showUp, .done: return 2 }
    }

    // MARK: Step 1 — choose

    private var chooseStep: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Choose a reset")
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("A small, shared moment. Pick what fits the week — there's no wrong choice.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(spacing: PillarsSpacing.s) {
                ForEach(resets) { r in
                    Button {
                        withAnimation(.smooth) { ritual = r; step = .invite }
                    } label: {
                        PillarGlassCard(padding: PillarsSpacing.m) {
                            HStack(spacing: PillarsSpacing.m) {
                                PillarIconBadge(pillar: r.pillar, size: 46)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(r.name)
                                        .font(PillarsTypography.headline)
                                        .foregroundStyle(PillarsColors.primaryText)
                                    Text(r.summary)
                                        .font(PillarsTypography.caption)
                                        .foregroundStyle(PillarsColors.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(PillarsColors.tertiaryText)
                            }
                        }
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
    }

    // MARK: Step 2 — invite

    private var inviteStep: some View {
        let r = ritual
        return VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Send the invite")
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("A warm, low-pressure message — yours to edit before it goes anywhere.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let r {
                PillarGlassCard {
                    VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                        HStack(spacing: PillarsSpacing.s) {
                            PillarIconBadge(pillar: r.pillar, size: 40)
                            Text(r.name)
                                .font(PillarsTypography.headline)
                                .foregroundStyle(PillarsColors.primaryText)
                        }
                        Text("“\(message(for: r))”")
                            .font(PillarsFont.serif(18, .regular))
                            .foregroundStyle(PillarsColors.primaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: PillarsSpacing.s) {
                    Button { copy(message(for: r)) } label: {
                        Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .font(PillarsTypography.callout.weight(.semibold))
                            .foregroundStyle(PillarsColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Capsule().fill(Color.white.opacity(0.06)))
                            .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())

                    ShareLink(item: message(for: r)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(PillarsTypography.callout.weight(.semibold))
                            .foregroundStyle(PillarsColors.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Capsule().fill(PillarsColors.gold))
                    }
                }

                PrimaryButton(title: "I sent it", icon: "arrow.right") {
                    withAnimation(.smooth) { step = .showUp }
                }
                .padding(.top, PillarsSpacing.xs)
            }
        }
    }

    // MARK: Step 3 — show up

    private var showUpStep: some View {
        let r = ritual
        return VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Show up")
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                Text("The invite is the hard part — you've done it. When the moment happens, mark it and share the win with your Circle.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let r {
                PillarGlassCard(highlight: true) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        ForEach(r.steps.indices, id: \.self) { i in
                            let s = r.steps[i]
                            HStack(alignment: .top, spacing: PillarsSpacing.s) {
                                Text("\(i + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(PillarsColors.gold)
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(PillarsColors.gold.opacity(0.14)))
                                Text(s)
                                    .font(PillarsTypography.callout)
                                    .foregroundStyle(PillarsColors.primaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                PrimaryButton(title: "I showed up", icon: "checkmark") { recordWin(r) }
                Text("This shares a win, not a score. Nothing else is revealed.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: Step 4 — done

    private var doneStep: some View {
        VStack(spacing: PillarsSpacing.l) {
            Spacer(minLength: PillarsSpacing.xl)
            ZStack {
                Circle().fill(PillarsColors.gold.opacity(0.14)).frame(width: 96, height: 96)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(PillarsColors.gold)
            }
            Text("Win shared")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
            Text("Showing up together is the whole point. Your Circle will see the win — never the scores behind it.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            PrimaryButton(title: "Back to Circle", icon: "arrow.right") { dismiss() }
                .padding(.top, PillarsSpacing.s)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, PillarsSpacing.xl)
    }

    // MARK: Logic

    private func message(for r: Ritual) -> String {
        r.shareMessage ?? "Want to do \(r.name) together this week? \(r.summary)"
    }

    private func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
        withAnimation { copied = true }
    }

    private func recordWin(_ r: Ritual) {
        let win = SharedWin(
            title: r.name,
            pillar: r.pillar,
            note: "We showed up together.",
            authorName: "You"
        )
        context.insert(win)
        // Recording the effect: a completed restoration also logs to the personal loop.
        let action = PillarAction(
            title: r.name, subtitle: r.summary, pillar: r.pillar,
            isCompleted: true, createdAt: .now, completedAt: .now
        )
        context.insert(action)
        try? context.save()
        withAnimation(.smooth) { step = .done }
    }
}

#if DEBUG
#Preview {
    SharedResetFlowView()
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
