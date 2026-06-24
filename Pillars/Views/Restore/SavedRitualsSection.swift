import SwiftUI
import SwiftData

/// Section: the rituals the user has chosen to keep close.
struct SavedRitualsSection: View {
    @Query(sort: \SavedRitual.savedAt, order: .reverse) private var saved: [SavedRitual]

    private var rituals: [Ritual] { RitualSaveStore.rituals(from: saved) }

    var body: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(title: "Saved Rituals", subtitle: "The practices you've kept close.")
            if rituals.isEmpty {
                RestoreEmptyCard(icon: "bookmark",
                                 title: "Nothing saved yet",
                                 message: "Open a ritual and tap Save to keep it here.")
            } else {
                ForEach(rituals) { ritual in
                    NavigationLink {
                        RitualDetailView(ritual: ritual)
                    } label: {
                        RestoreRitualCard(ritual: ritual)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
