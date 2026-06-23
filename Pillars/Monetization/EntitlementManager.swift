import Foundation
import StoreKit
import Observation

/// Owns subscription state and gating decisions.
///
/// Uses real StoreKit 2 APIs when products are configured, and falls back to a local
/// **mock mode** otherwise — so the whole monetization flow is testable offline, with no
/// real product IDs required (per the v0.4 plan). Mock entitlements persist in
/// `UserDefaults`; real entitlements come from `Transaction.currentEntitlements`.
@Observable
@MainActor
final class EntitlementManager {

    /// Tiers the user currently holds (beyond Free).
    private(set) var ownedTiers: Set<SubscriptionTier> = []
    /// Real StoreKit products, when available.
    private(set) var products: [Product] = []
    /// True when no real StoreKit products are configured — purchases are simulated.
    private(set) var isMockMode: Bool = true
    var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private let mockKey = "pillars.mockOwnedTiers"

    init() {
        loadMockEntitlements()
    }

    /// Kick off product loading, entitlement refresh, and the transaction listener.
    func start() async {
        await loadProducts()
        await refreshEntitlements()
        observeTransactions()
    }

    // MARK: Gating

    func isEntitled(to feature: Feature) -> Bool {
        let required = feature.requiredTiers
        if required.contains(.free) { return true }
        return !required.isDisjoint(with: ownedTiers)
    }

    var hasPlus: Bool { ownedTiers.contains(.plus) }
    var hasCirclePass: Bool { ownedTiers.contains(.circlePass) }

    /// A short label for the current plan(s).
    var planSummary: String {
        if ownedTiers.isEmpty { return "Free" }
        return ownedTiers.sorted().map(\.displayName).joined(separator: " + ")
    }

    func owns(_ tier: SubscriptionTier) -> Bool {
        tier == .free || ownedTiers.contains(tier)
    }

    // MARK: StoreKit

    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: ProductCatalog.allIDs)
            products = loaded.sorted { $0.price < $1.price }
            isMockMode = loaded.isEmpty
        } catch {
            products = []
            isMockMode = true
            lastErrorMessage = error.localizedDescription
        }
    }

    func product(id: String) -> Product? { products.first { $0.id == id } }

    func refreshEntitlements() async {
        // In mock mode, ownership is driven locally (UserDefaults), not by StoreKit.
        guard !isMockMode else { return }
        var owned: Set<SubscriptionTier> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.revocationDate == nil else { continue }
            if let tier = ProductCatalog.tier(for: transaction.productID) {
                owned.insert(tier)
            }
        }
        ownedTiers = owned
    }

    private func observeTransactions() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else { continue }
                await transaction.finish()
                await self?.refreshEntitlements()
            }
        }
    }

    /// Purchase a real product (or simulate if we're in mock mode).
    func purchase(productID: String, mockTier: SubscriptionTier) async {
        if isMockMode {
            mockPurchase(mockTier)
            return
        }
        guard let product = product(id: productID) else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func restore() async {
        guard !isMockMode else { return }
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: Mock controls (development)

    func mockPurchase(_ tier: SubscriptionTier) {
        guard tier != .free else { return }
        ownedTiers.insert(tier)
        saveMockEntitlements()
    }

    /// Directly set owned tiers — used by the developer toggle in Settings.
    func setMockTiers(_ tiers: Set<SubscriptionTier>) {
        ownedTiers = tiers.filter { $0 != .free }
        saveMockEntitlements()
    }

    private func loadMockEntitlements() {
        let raw = UserDefaults.standard.stringArray(forKey: mockKey) ?? []
        ownedTiers = Set(raw.compactMap { SubscriptionTier(rawValue: $0) })
    }

    private func saveMockEntitlements() {
        UserDefaults.standard.set(ownedTiers.map(\.rawValue), forKey: mockKey)
    }

    #if DEBUG
    /// Deterministic instance for previews (does not touch `UserDefaults`).
    static func preview(_ tiers: Set<SubscriptionTier> = []) -> EntitlementManager {
        let manager = EntitlementManager()
        manager.ownedTiers = tiers
        return manager
    }
    #endif
}
