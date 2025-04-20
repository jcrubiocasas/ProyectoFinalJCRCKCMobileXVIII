//
//  Security+Application.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 18/4/25.
//

import Vapor

extension Application {
    private struct SecurityTokenKey: StorageKey {
        typealias Value = SecurityTokenService
    }

    var securityTokenService: SecurityTokenService {
        get {
            self.storage[SecurityTokenKey.self]!
        }
        set {
            self.storage[SecurityTokenKey.self] = newValue
        }
    }
}
