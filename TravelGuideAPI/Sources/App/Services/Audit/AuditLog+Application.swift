//
//  AuditLog+Application.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 20/4/25.
//

import Vapor

extension Application {
    private struct AuditLogServiceKey: StorageKey {
        typealias Value = any AuditLogService
    }

    var auditLogService: any AuditLogService {
        get { self.storage[AuditLogServiceKey.self]! }
        set { self.storage[AuditLogServiceKey.self] = newValue }
    }
}
