// MARK: - SearchHistory.swift corregido

import Fluent
import Vapor

final class SearchHistory: Model, Content, @unchecked Sendable {
    static let schema = "search_history"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "destination")
    var destination: String

    @Field(key: "title")
    var title: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, destination: String, title: String) {
        self.id = id
        self.$user.id = userID
        self.destination = destination
        self.title = title
    }
}
