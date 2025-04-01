//
//  AIController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor

struct AIController: RouteCollection {
    let chatService: ChatGPTService

    init(chatService: ChatGPTService) {
        self.chatService = chatService
    }

    func boot(routes: any RoutesBuilder) throws {
        let aiRoutes = routes.grouped("ai")
        aiRoutes.post("generate-itineraries", use: generateItineraries)
    }

    func generateItineraries(req: Request) async throws -> [ItineraryDTO] {
        let promptDTO = try req.content.decode(ItineraryPromptRequestDTO.self)
        return try await chatService.generateItinerary(from: promptDTO)
    }
}
