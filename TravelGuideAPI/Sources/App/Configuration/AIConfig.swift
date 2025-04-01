//
//  AIConfig.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 31/3/25.
//

// App/Config/AIConfig.swift
import Vapor

extension Application {
    func setupChatGPTService() throws {
        guard let openAIToken = Environment.get("OPENAI_KEY") else {
            fatalError("❌ Falta OPENAI_KEY en el entorno")
        }

        self.chatGPTService = ChatGPTService(
            client: self.client,
            gptToken: openAIToken,
            app: self
        )
    }
}
