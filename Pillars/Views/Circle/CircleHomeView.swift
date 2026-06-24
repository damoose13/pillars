import SwiftUI
import SwiftData

/// Circle mode home. Create a Circle, invite trusted (mock) people, and see the
/// privacy-safe Pulse, shared resets, and voluntary wins. Individual scores never appear.
struct CircleHomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(EntitlementManager.self) private var entitlements

    @Query private var circles: [CircleGroup]
    @Query(sort: \CircleMember.joinedAt, order: .forward) private var members: [CircleMember]
    @Query(sort: \SharedWin.createdAt, order: .reverse) private var wins: [SharedWin]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    @State private var showComposer = false
    @State private var showPrivacy = false
    @State private var showAddPeople = false
    @State private var showLeaveConfirm = false
    @State private var showPaywall = false
    @State private var showSharedReset = false

    private var hasCircle: Bool { !circles.isEmpty }

    private var winsThisWeek: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .distantPast
        return wins.filter { $0.createdAt >= cutoff }.count
    }

    private var pulse: CirclePulse {
        CirclePulseEngine.pulse(members: members, winsThisWeek: winsThisWeek)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
                    if hasCircle {
                        circleHeader
                        if entitlements.isEntitled(to: .circlePulse) {
                            CirclePulseView(pulse: pulse)
                            actionsSection
                        } else {
                            LockedFeatureCard(feature: .circlePulse) { showPaywall = true }
                        }
                        winsSection
                        manageSection
                    } else {
                        createState
                    }
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .toolbar(.hidden, for: .navigationBar)
            .onAppear(perform: syncYou)
            .sheet(isPresented: $showComposer) { SharedWinComposerView() }
            .sheet(isPresented: $showPrivacy) { PrivacyExplainerView() }
            .sheet(isPresented: $showAddPeople) { AddPeopleSheet() }
            .sheet(isPresented: $showPaywall) { PaywallView(highlightTier: .circlePass) }
            .sheet(isPresented: $showSharedReset) { SharedResetFlowView() }
            .confirmationDialog("Leave this Circle?", isPresented: $showLeaveConfirm, titleVisibility: .visible) {
                Button("Leave Circle", role: .destructive) { leaveCircle() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes the Circle and its members from this device. Your own check-ins and history are untouched.")
            }
        }
    }

    // MARK: Header

    private var circleHeader: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            HStack {
                Text("Circle")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                Spacer()
                Button { showPrivacy = true } label: {
                    Label("Privacy", systemImage: "lock.fill")
                        .font(PillarsTypography.caption.weight(.semibold))
                        .foregroundStyle(PillarsColors.secondaryText)
                }
                .buttonStyle(.plain)
            }

            Text(circles.first?.name ?? "My Circle")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)

            HStack(spacing: PillarsSpacing.s) {
                avatarStack
                Spacer(minLength: 0)
                privacyChip
            }
        }
    }

    private var avatarStack: some View {
        HStack(spacing: -10) {
            ForEach(members.prefix(6)) { member in
                MemberAvatar(name: member.name, colorIndex: member.colorIndex, isYou: member.isYou, size: 40)
            }
            if members.count > 6 {
                Text("+\(members.count - 6)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PillarsColors.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                    .overlay(Circle().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
            }
        }
    }

    private var privacyChip: some View {
        Label("Private · \(members.count) \(members.count == 1 ? "person" : "people")", systemImage: "lock.fill")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(PillarsColors.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(Color.white.opacity(0.05)))
            .overlay(Capsule().strokeBorder(PillarsColors.cardBorder, lineWidth: 1))
    }

    // MARK: Actions

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(
                title: pulse.isAlone ? "Grow your Circle" : "Shared resets",
                subtitle: pulse.isAlone ? "Better together." : "Small, optional, no pressure.",
                actionTitle: pulse.isAlone ? nil : "Invite",
                action: { showAddPeople = true }
            )
            ForEach(pulse.actions) { action in
                CircleActionSuggestionView(action: action, onStart: { showSharedReset = true })
            }
            if !pulse.isAlone {
                PrimaryButton(title: "Start a shared reset", icon: "sparkles") { showSharedReset = true }
                    .padding(.top, PillarsSpacing.xxs)
                Text("A shared reset walks you through choosing a moment, inviting someone, and showing up — no one ever sees your scores.")
                    .font(PillarsTypography.caption)
                    .foregroundStyle(PillarsColors.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Wins

    private var winsSection: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.m) {
            SectionHeader(
                title: "Shared wins",
                subtitle: "Voluntary, and always yours to choose.",
                actionTitle: "Share",
                action: { showComposer = true }
            )
            if wins.isEmpty {
                PillarGlassCard {
                    VStack(spacing: PillarsSpacing.s) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 26, weight: .light))
                            .foregroundStyle(PillarsColors.gold)
                        Text("No wins shared yet")
                            .font(PillarsTypography.headline)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text("Be the first to name a small win. It sets the tone for the whole Circle.")
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(wins) { win in
                    SharedWinRow(win: win)
                }
            }
        }
    }

    // MARK: Manage

    private var manageSection: some View {
        VStack(spacing: PillarsSpacing.m) {
            SecondaryButton(title: "Add trusted people", icon: "person.badge.plus") { showAddPeople = true }
            Button(role: .destructive) { showLeaveConfirm = true } label: {
                Text("Leave Circle")
                    .font(PillarsTypography.callout.weight(.semibold))
                    .foregroundStyle(PillarsColors.caution)
            }
            .buttonStyle(.plain)
            .padding(.top, PillarsSpacing.xxs)
        }
        .padding(.top, PillarsSpacing.s)
    }

    // MARK: Create state

    private var createState: some View {
        VStack(alignment: .leading, spacing: PillarsSpacing.xl) {
            VStack(alignment: .leading, spacing: PillarsSpacing.s) {
                Text("Circles")
                    .pillarsOverline(PillarsColors.gold.opacity(0.9))
                Text("Support, without\nexposure.")
                    .font(PillarsTypography.display)
                    .foregroundStyle(PillarsColors.primaryText)
                    .lineSpacing(2)
                Text("Invite a few trusted people and support each other — without ever sharing private scores. The smaller the Circle, the less it shows.")
                    .font(PillarsTypography.body)
                    .foregroundStyle(PillarsColors.secondaryText)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            PillarGlassCard(highlight: true) {
                VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                    Label { Text("Private by design") } icon: { Image(systemName: "lock.shield.fill") }
                        .pillarsOverline(PillarsColors.gold.opacity(0.9))
                    Text("Pillars blurs everything a Circle sees, scaled to its size. Individual scores never leave your device.")
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Button { showPrivacy = true } label: {
                        Text("How privacy works →")
                            .font(PillarsTypography.caption.weight(.semibold))
                            .foregroundStyle(PillarsColors.gold)
                    }
                    .buttonStyle(.plain)
                }
            }

            PrimaryButton(title: "Create a Circle", icon: "person.3.fill") { createCircle() }

            Text("For now, members are simulated on your device. Real invites arrive with accounts later.")
                .font(PillarsTypography.caption)
                .foregroundStyle(PillarsColors.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, PillarsSpacing.l)
    }

    // MARK: Mutations

    private func createCircle() {
        let circle = CircleGroup(name: "My Circle")
        context.insert(circle)

        let you = CircleMember(name: "You", colorIndex: 0, isYou: true)
        if let latest = checkIns.first {
            for pillar in PillarType.allCases { you.setScore(latest.score(for: pillar), for: pillar) }
        }
        context.insert(you)
        try? context.save()
    }

    /// Keep the user's own (aggregate-only) signal current from their latest check-in.
    private func syncYou() {
        guard let you = members.first(where: { $0.isYou }), let latest = checkIns.first else { return }
        for pillar in PillarType.allCases { you.setScore(latest.score(for: pillar), for: pillar) }
        try? context.save()
    }

    private func leaveCircle() {
        for member in members { context.delete(member) }
        for circle in circles { context.delete(circle) }
        try? context.save()
    }
}

// MARK: - Shared win row

private struct SharedWinRow: View {
    let win: SharedWin

    var body: some View {
        PillarGlassCard(padding: PillarsSpacing.m) {
            HStack(alignment: .top, spacing: PillarsSpacing.m) {
                PillarIconBadge(pillar: win.pillar, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(win.title)
                        .font(PillarsTypography.headline)
                        .foregroundStyle(PillarsColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    if let note = win.note, !note.isEmpty {
                        Text(note)
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 6) {
                        MetaChip(text: win.authorName, color: PillarsColors.gold)
                        MetaChip(text: win.pillar.displayName, color: win.pillar.color)
                        Text(win.createdAt.formatted(.relative(presentation: .named)))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(PillarsColors.tertiaryText)
                    }
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Add people sheet

private struct AddPeopleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \CircleMember.joinedAt, order: .forward) private var members: [CircleMember]

    private var available: [String] {
        let taken = Set(members.map(\.name))
        return CircleMember.sampleRoster.filter { !taken.contains($0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PillarsSpacing.l) {
                    Text("Adding people is simulated for now — it's how you can feel the privacy tiers change as a Circle grows.")
                        .font(PillarsTypography.callout)
                        .foregroundStyle(PillarsColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    if available.isEmpty {
                        PillarGlassCard {
                            Text("Everyone in the sample roster has joined.")
                                .font(PillarsTypography.body)
                                .foregroundStyle(PillarsColors.secondaryText)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        VStack(spacing: PillarsSpacing.s) {
                            ForEach(available.indices, id: \.self) { index in
                                let name = available[index]
                                Button { add(name: name, colorIndex: members.count + index) } label: {
                                    PillarGlassCard(padding: PillarsSpacing.m) {
                                        HStack(spacing: PillarsSpacing.m) {
                                            MemberAvatar(name: name, colorIndex: members.count + index, size: 40)
                                            Text(name)
                                                .font(PillarsTypography.headline)
                                                .foregroundStyle(PillarsColors.primaryText)
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(PillarsColors.gold)
                                        }
                                    }
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        }
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
            .navigationTitle("Invite people")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(PillarsColors.gold)
                }
            }
        }
    }

    private func add(name: String, colorIndex: Int) {
        let member = CircleMember.mock(name: name, colorIndex: colorIndex)
        context.insert(member)
        try? context.save()
    }
}

#if DEBUG
#Preview {
    CircleHomeView()
        .environment(AppState())
        .environment(EntitlementManager.preview([.circlePass]))
        .modelContainer(PreviewData.container)
        .preferredColorScheme(.dark)
}
#endif
