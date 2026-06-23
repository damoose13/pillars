import SwiftUI
import SwiftData

/// Compose a voluntary win to share with the Circle. The one thing a member ever attributes
/// to themselves — and always by choice.
struct SharedWinComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var pillar: PillarType = .connect
    @State private var title: String = ""
    @State private var note: String = ""

    private var canShare: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                        Text("Share a win")
                            .font(PillarsTypography.display)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Small wins are worth saying out loud. Only what you write here is shared — never a score.")
                            .font(PillarsTypography.body)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PillarGlassCard {
                        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                            Text("Which pillar?")
                                .pillarsOverline()
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
                                ForEach(PillarType.allCases) { option in
                                    pillarPill(option)
                                }
                            }
                        }
                    }

                    PillarGlassCard {
                        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                            field(title: "The win", placeholder: "What went well?", text: $title, lines: 1...2)
                            field(title: "A little more (optional)", placeholder: "Add a sentence if you'd like", text: $note, lines: 2...4)
                        }
                    }

                    PrimaryButton(title: "Share with Circle", icon: "sparkles") { share() }
                        .disabled(!canShare)
                        .opacity(canShare ? 1 : 0.5)
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("New win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(PillarsColors.secondaryText)
                }
            }
        }
    }

    private func pillarPill(_ option: PillarType) -> some View {
        let selected = option == pillar
        return Button {
            withAnimation(.snappy) { pillar = option }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.icon).font(.system(size: 12, weight: .semibold))
                Text(option.displayName).font(PillarsTypography.caption.weight(.medium))
            }
            .foregroundStyle(selected ? PillarsColors.background : PillarsColors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Capsule().fill(selected ? option.color : Color.white.opacity(0.05)))
            .overlay(Capsule().strokeBorder(selected ? Color.clear : PillarsColors.cardBorder, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func field(title: String, placeholder: String, text: Binding<String>, lines: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
            Text(title)
                .font(PillarsTypography.caption.weight(.semibold))
                .foregroundStyle(PillarsColors.secondaryText)
            TextField(placeholder, text: text, axis: .vertical)
                .lineLimit(lines)
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.primaryText)
                .tint(PillarsColors.gold)
                .padding(PillarsSpacing.s)
                .background(RoundedRectangle(cornerRadius: PillarsRadius.small).fill(Color.white.opacity(0.04)))
                .overlay(RoundedRectangle(cornerRadius: PillarsRadius.small).strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
        }
    }

    private func share() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let win = SharedWin(
            title: trimmedTitle,
            pillar: pillar,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            authorName: "You"
        )
        context.insert(win)
        try? context.save()
        dismiss()
    }
}

#if DEBUG
#Preview {
    SharedWinComposerView()
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
