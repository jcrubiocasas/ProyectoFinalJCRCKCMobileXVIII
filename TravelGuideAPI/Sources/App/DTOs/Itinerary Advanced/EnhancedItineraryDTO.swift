//
//  EnhancedItineraryDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Vapor

struct EnhancedItineraryDTO: Content {
    var id: String?
    var title: String
    var description: String
    var duration: Int
    var imageAI: String
    var imageReal: String?
    var latitude: Double
    var longitude: Double
    var address: String?
    var website: String?
    var phone: String?
    var opening_hours: String?
    var source: String
    var category: PromptType? // 👈 NUEVO, opcional si lo quieres conservar

    static func from(itinerary: ItineraryDTO, type: PromptType) -> EnhancedItineraryDTO {
        return EnhancedItineraryDTO(
            id: itinerary.id,
            title: itinerary.title,
            description: itinerary.description,
            duration: itinerary.duration,
            imageAI: itinerary.image,
            imageReal: nil,
            latitude: itinerary.latitude,
            longitude: itinerary.longitude,
            address: nil,
            website: nil,
            phone: nil,
            opening_hours: nil,
            source: "IA",
            category: type
        )
    }
}
