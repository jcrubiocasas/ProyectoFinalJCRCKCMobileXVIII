//
//  ChatGPTService+Application.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 28/3/25.
//

import Vapor

extension Application {
    private struct ChatGPTServiceKey: StorageKey {
        typealias Value = ChatGPTService
    }

    var chatGPTService: ChatGPTService {
        get {
            guard let service = self.storage[ChatGPTServiceKey.self] else {
                fatalError("ChatGPTService no ha sido configurado. Usa app.chatGPTService = ... en configure.swift")
            }
            return service
        }
        set {
            self.storage[ChatGPTServiceKey.self] = newValue
        }
    }
}
