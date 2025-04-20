//
//  ItineraryOrchestratorService.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Vapor

final class ItineraryOrchestratorService {
    private let gptService: ChatGPTService
    private let googleService: GooglePlacesService

    init(gptService: ChatGPTService, googleService: GooglePlacesService) {
        self.gptService = gptService
        self.googleService = googleService
    }

    /// Genera itinerarios combinando IA + Google Places
    func generateEnhancedItineraries(from request: ItineraryPromptRequestDTO, type: PromptType) async throws -> [EnhancedItineraryDTO] {
        let baseItineraries = try await gptService.generateItinerary(from: request)
        var enriched: [EnhancedItineraryDTO] = []

        for item in baseItineraries.itineraries {
            var enrichedItem = EnhancedItineraryDTO.from(itinerary: item, type: type)
            
            if let googleData = try? await googleService.findPlace(named: item.title, near: item.latitude, lon: item.longitude) {
                enrichedItem.imageReal = googleData.imageUrl
                enrichedItem.address = googleData.address
                enrichedItem.website = googleData.website
                enrichedItem.phone = googleData.phone
                enrichedItem.opening_hours = googleData.openingHours
                enrichedItem.source = "GPTravel"
            }

            enriched.append(enrichedItem)
        }

        return enriched
    }
}
