// MARK: - CreateEmergencySession.swift

import Fluent

struct CreateEmergencySession: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("emergency_sessions")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("emergency_email", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("token", .string, .required)
            .field("is_active", .bool, .required, .sql(.default(true)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("emergency_sessions").delete()
    }
}
