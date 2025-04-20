//
//  AuditLog.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 20/4/25.
//

import Vapor
import Fluent

final class AuditLog: Model, Content, @unchecked Sendable {
    static let schema = "audit_logs"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userID: UUID

    @Field(key: "action")
    var action: String

    @Field(key: "description")
    var description: String

    @Field(key: "ip_address")
    var ipAddress: String?

    @Field(key: "user_agent")
    var userAgent: String?

    @Field(key: "timestamp")
    var timestamp: Date

    init() {}

    init(userID: UUID, action: String, description: String, ipAddress: String?, userAgent: String?) {
        self.userID = userID
        self.action = action
        self.description = description
        self.ipAddress = ipAddress
        self.userAgent = userAgent
        self.timestamp = Date()
    }
}
