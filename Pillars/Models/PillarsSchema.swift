import Foundation
import SwiftData

/// Versioned schema + migration plan for the local store.
///
/// Today there is a single version, so no data migrates. But by routing the container through
/// a `SchemaMigrationPlan` now, any future model change can add a `V2` and a `MigrationStage`
/// without risking a shipped user's history — the safety net is in place before it's needed.
enum PillarsSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [DailyCheckIn.self, PillarAction.self, CircleGroup.self, CircleMember.self, SharedWin.self]
    }
}

enum PillarsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PillarsSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []  // Add a stage here when introducing PillarsSchemaV2.
    }
}
