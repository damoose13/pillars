import SwiftUI

/// A low-pressure way to let the Circle know you're here — no performance, no fixing, no
/// scores. Pick a warm starter or write your own, and send a single gentle line to the group.
/// (Members are simulated for now, so this previews the experience until accounts arrive.)
struct GentleCheckInComposerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var sent = false

    private let starters = [
        "Thinking of you all — how's everyone holding up?",
        "No agenda. Just checking in on the Circle.",
        "Here for a quiet hour this week if anyone needs one.",
        "Rooting for everyone. What's one small thing today?"
    ]

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    if sent { sentCard } else { composer }
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Gentle check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(sent ? "Done" : "Cancel") { dismiss() }
                        .foregroundStyle(PillarsColors.secondaryText)
                }
            }
        }
    }

    // MARK: Composer

    private var composer: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Let the Circle know you're here.")
                    .font(PillarsTypography.title)
                    .foregroundStyle(PillarsColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text("No performance, no fixing — just presence. Pick a starter or write your own.")
                    .font(PillarsTypography.callout)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Starters")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                ForEach(starters.indices, id: \.self) { i in
                    Button {
                        withAnimation(.smooth(duration: 0.2)) { text = starters[i] }
                    } label: {
                        HStack(spacing: PillarsSpacing.s) {
                            Image(systemName: text == starters[i] ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundStyle(text == starters[i] ? PillarsColors.gold : PillarsColors.tertiaryText)
                            Text(starters[i])
                                .font(PillarsTypography.callout)
                                .foregroundStyle(PillarsColors.primaryText)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(PillarsSpacing.m)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(text == starters[i] ? 0.06 : 0.03)))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(text == starters[i] ? PillarsColors.gold.opacity(0.45) : PillarsColors.cardBorder, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }

            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Your message")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                PillarGlassCard(padding: PillarsSpacing.m) {
                    TextField("Write something gentle…", text: $text, axis: .vertical)
                        .font(PillarsTypography.body)
                        .foregroundStyle(PillarsColors.primaryText)
                        .lineLimit(3...6)
                        .tint(PillarsColors.gold)
                }
            }

            PrimaryButton(title: "Send to Circle", icon: "paperplane.fill") { send() }
                .opacity(trimmed.isEmpty ? 0.5 : 1)
                .disabled(trimmed.isEmpty)

            Label("Nobody sees a score, and there are no likes or replies to perform for. Real delivery arrives with accounts.",
                  systemImage: "hand.raised.fill")
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Sent

    private var sentCard: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            PillarGlassCard(highlight: true) {
                VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(PillarsColors.gold)
                    Text("Your check-in is ready for the Circle.")
                        .font(PillarsTypography.title)
                        .foregroundStyle(PillarsColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    if !trimmed.isEmpty {
                        Text("“\(trimmed)”")
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Presence is the whole point — you showed up. Real delivery arrives with accounts.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            PrimaryButton(title: "Done", icon: "checkmark") { dismiss() }
        }
    }

    private func send() {
        guard !trimmed.isEmpty else { return }
        withAnimation(.smooth) { sent = true }
    }
}

#if DEBUG
#Preview {
    GentleCheckInComposerView()
        .preferredColorScheme(.dark)
}
#endif
