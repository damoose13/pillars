import SwiftUI
import StoreKit

/// The paywall. Presents Pillars Plus and Circle Pass. Uses real StoreKit products when
/// configured, and a local mock catalog otherwise so the flow is fully testable offline.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(EntitlementManager.self) private var entitlements

    /// Optional tier to feature first (e.g. when arriving from a Circle gate).
    var highlightTier: SubscriptionTier = .plus

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PillarsSpacing.xl) {
                    headerView

                    planCard(
                        tier: .plus,
                        tagline: "Go deeper, on your own.",
                        bullets: [
                            "Your complete check-in history",
                            "Weekly & monthly reviews",
                            "Advanced insights and patterns",
                            "Everything in Free"
                        ]
                    )

                    planCard(
                        tier: .circlePass,
                        tagline: "Hold a Circle, privately.",
                        bullets: [
                            "Circle Pulse & shared resets",
                            "Voluntary shared wins",
                            "Multiple Circles",
                            "Circle weekly report"
                        ]
                    )

                    footerView
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PillarsSpacing.screenH)
                .padding(.top, PillarsSpacing.m)
                .padding(.bottom, PillarsSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .pillarsBackground()
            .navigationTitle("Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }.foregroundStyle(PillarsColors.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restore") { Task { await entitlements.restore() } }
                        .foregroundStyle(PillarsColors.gold)
                        .disabled(entitlements.isMockMode)
                }
            }
        }
    }

    // MARK: Header

    private var headerView: some View {
        VStack(spacing: PillarsSpacing.s) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(PillarsColors.gold)
            Text("Support the whole structure.")
                .font(PillarsTypography.display)
                .foregroundStyle(PillarsColors.primaryText)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            Text("The daily loop is always free. Upgrade only if you want more depth or a Circle.")
                .font(PillarsTypography.body)
                .foregroundStyle(PillarsColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Plan card

    private func planCard(tier: SubscriptionTier, tagline: String, bullets: [String]) -> some View {
        let owned = entitlements.owns(tier)
        return PillarGlassCard(highlight: tier == highlightTier && !owned) {
            VStack(alignment: .leading, spacing: PillarsSpacing.m) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tier.displayName)
                            .font(PillarsTypography.title)
                            .foregroundStyle(PillarsColors.primaryText)
                        Text(tagline)
                            .font(PillarsTypography.callout)
                            .foregroundStyle(PillarsColors.secondaryText)
                    }
                    Spacer()
                    if owned {
                        Label("Active", systemImage: "checkmark.seal.fill")
                            .font(PillarsTypography.caption.weight(.semibold))
                            .foregroundStyle(PillarsColors.positive)
                    }
                }

                VStack(alignment: .leading, spacing: PillarsSpacing.xs) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: PillarsSpacing.s) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(PillarsColors.gold)
                                .padding(.top, 3)
                            Text(bullet)
                                .font(PillarsTypography.callout)
                                .foregroundStyle(PillarsColors.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                if owned {
                    Text("You're all set. Thank you for supporting Pillars.")
                        .font(PillarsTypography.caption)
                        .foregroundStyle(PillarsColors.tertiaryText)
                } else {
                    purchaseButtons(for: tier)
                }
            }
        }
    }

    private func purchaseButtons(for tier: SubscriptionTier) -> some View {
        // Real products if present, else the mock catalog.
        let realProducts = entitlements.products.filter { ProductCatalog.tier(for: $0.id) == tier }

        return VStack(spacing: PillarsSpacing.s) {
            if realProducts.isEmpty {
                ForEach(ProductCatalog.mockProducts(for: tier)) { mock in
                    purchaseButton(
                        title: mock.isYearly ? "Yearly" : "Monthly",
                        price: "\(mock.displayPrice) / \(mock.period)",
                        prominent: mock.isYearly
                    ) {
                        Task { await entitlements.purchase(productID: mock.id, mockTier: tier) }
                    }
                }
                Text("Simulated checkout · no charge in mock mode")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(PillarsColors.tertiaryText)
            } else {
                ForEach(realProducts, id: \.id) { product in
                    purchaseButton(
                        title: product.displayName,
                        price: product.displayPrice,
                        prominent: product.id.hasSuffix("yearly")
                    ) {
                        Task { await entitlements.purchase(productID: product.id, mockTier: tier) }
                    }
                }
            }
        }
    }

    private func purchaseButton(title: String, price: String, prominent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(PillarsTypography.headline)
                Spacer()
                Text(price).font(PillarsTypography.callout.weight(.semibold))
            }
            .foregroundStyle(prominent ? PillarsColors.background : PillarsColors.primaryText)
            .padding(.horizontal, PillarsSpacing.m)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(prominent ? AnyShapeStyle(PillarsColors.gold) : AnyShapeStyle(Color.white.opacity(0.05)))
            )
            .overlay(Capsule().strokeBorder(prominent ? Color.clear : PillarsColors.cardBorder, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: Footer

    private var footerView: some View {
        VStack(spacing: PillarsSpacing.xs) {
            Text("Subscriptions renew until cancelled. Manage anytime in the App Store.")
            Text("Your private data stays on your device regardless of plan.")
        }
        .font(.system(size: 11))
        .foregroundStyle(PillarsColors.tertiaryText)
        .multilineTextAlignment(.center)
        .padding(.top, PillarsSpacing.xs)
    }
}

#if DEBUG
#Preview {
    PaywallView()
        .environment(EntitlementManager())
        .preferredColorScheme(.dark)
}
#endif
