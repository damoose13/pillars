import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The editable invitation for a shared reset. It seeds a warm default from the chosen ritual,
/// lets you make it your own, then copy or share it. Nothing sends automatically — the words
/// are yours, and they only leave the device when you choose to share them.
struct ResetMessageComposerView: View {
    let ritual: Ritual
    @Binding var message: String
    var onSent: () -> Void

    @State private var copied = false

    private var trimmed: String { message.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.l) {
            PillarGlassCard {
                VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                    HStack(spacing: PillarsSpacing.s) {
                        PillarIconBadge(pillar: ritual.pillar, size: 40)
                        Text(ritual.name)
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                    }
                    TextField("Write your invitation…", text: $message, axis: .vertical)
                        .font(PillarsFont.serif(18, .regular))
                        .foregroundStyle(PillarsColors.primaryText)
                        .lineLimit(3...8)
                        .lineSpacing(3)
                        .tint(PillarsColors.gold)
                    Text("Make it yours — tone, length, anything. It only goes where you send it.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: PillarsSpacing.s) {
                Button { copy() } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(PillarsTypography.callout.weight(.semibold))
                        .foregroundStyle(PillarsColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                        .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(trimmed.isEmpty)

                ShareLink(item: trimmed) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(PillarsTypography.callout.weight(.semibold))
                        .foregroundStyle(PillarsColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(PillarsColors.gold))
                }
                .disabled(trimmed.isEmpty)
            }

            PrimaryButton(title: "I sent it", icon: "arrow.right") { onSent() }
                .opacity(trimmed.isEmpty ? 0.5 : 1)
                .disabled(trimmed.isEmpty)
                .padding(.top, PillarsSpacing.xs)
        }
    }

    private func copy() {
        #if canImport(UIKit)
        UIPasteboard.general.string = trimmed
        #endif
        withAnimation { copied = true }
    }
}
