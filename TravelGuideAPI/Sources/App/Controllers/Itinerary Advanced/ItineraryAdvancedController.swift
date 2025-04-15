//
//  ItineraryAdvancedController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Vapor
import JWT

struct ItineraryAdvancedController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("ai", "generate-advanced-itinerary", use: generate)
    }

    func generate(req: Request) async throws -> [EnhancedItineraryDTO] {
        let user = try req.auth.require(UserPayload.self)
        let promptDTO = try req.content.decode(ItineraryPromptRequestDTO.self)

        let gpt = req.application.chatGPTService
        let google = req.application.googlePlacesService
        let orchestrator = ItineraryOrchestratorService(gptService: gpt, googleService: google)

        return try await orchestrator.generateEnhancedItineraries(from: promptDTO, type: .tourism)
    }
}
