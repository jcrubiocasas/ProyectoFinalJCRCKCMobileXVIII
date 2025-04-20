//
//  AuditLogService.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 20/4/25.
//

import Vapor
import Fluent

protocol AuditLogService: Sendable {
    func log(req: Request, userID: UUID, action: String, description: String) async throws
}

struct DefaultAuditLogService: AuditLogService, Sendable {
    func log(req: Request, userID: UUID, action: String, description: String) async throws {
        let ip = req.headers.forwarded.first?.for ?? req.remoteAddress?.ipAddress ?? "unknown"
        let userAgent = req.headers.first(name: .userAgent) ?? "unknown"

        let entry = AuditLog(
            userID: userID,
            action: action,
            description: description,
            ipAddress: ip,
            userAgent: userAgent
        )

        try await entry.save(on: req.db)
    }
}
