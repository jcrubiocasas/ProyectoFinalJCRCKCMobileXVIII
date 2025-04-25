import Fluent

struct CreateSearchHistory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("search_history")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("destination", .string, .required)
            .field("title", .string, .required)
            .field("created_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("search_history").delete()
    }
}
