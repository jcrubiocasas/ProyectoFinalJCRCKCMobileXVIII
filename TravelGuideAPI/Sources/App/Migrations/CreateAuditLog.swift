//
//  CreateAuditLog.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 20/4/25.
//

import Fluent

struct CreateAuditLog: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("audit_logs")
            .id()
            .field("user_id", .uuid, .required)
            .field("action", .string, .required)
            .field("description", .string, .required)
            .field("ip_address", .string)
            .field("user_agent", .string)
            .field("timestamp", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("audit_logs").delete()
    }
}
