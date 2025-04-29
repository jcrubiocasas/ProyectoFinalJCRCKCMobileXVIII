import Vapor
import Fluent

final class EmergencySession: Model, Content, @unchecked Sendable {
    static let schema = "emergency_sessions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "emergency_email")
    var emergencyEmail: String

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    @Field(key: "token")
    var token: String

    @Field(key: "is_active")
    var isActive: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userID: UUID,
        emergencyEmail: String,
        latitude: Double,
        longitude: Double,
        token: String
    ) {
        self.id = id
        self.$user.id = userID
        self.emergencyEmail = emergencyEmail
        self.latitude = latitude
        self.longitude = longitude
        self.token = token
        self.isActive = true
    }
}
