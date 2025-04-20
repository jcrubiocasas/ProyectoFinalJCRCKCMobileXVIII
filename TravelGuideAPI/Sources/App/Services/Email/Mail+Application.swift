//
//  Mail+Application.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 18/4/25.
//

import Vapor

extension Application {
    private struct MailServiceKey: StorageKey {
        typealias Value = MailService
    }

    var mailService: MailService {
        get { self.storage[MailServiceKey.self]! }
        set { self.storage[MailServiceKey.self] = newValue }
    }
}
