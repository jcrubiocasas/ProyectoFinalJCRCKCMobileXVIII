//
//  AdvancedItineraryController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 17/4/25.
//

import Vapor
import Fluent

struct AdvancedItineraryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("advanced-itineraries", "save", use: save)
        routes.get("advanced-itineraries", "list", use: list)
        routes.delete("advanced-itineraries", "delete", ":id", use: delete)
    }

    func save(req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(UserPayload.self)
        let dto = try req.content.decode(AdvancedItineraryDTO.self)

        let itinerary = AdvancedItinerary(
            userID: payload.id,
            title: dto.title,
            description: dto.description,
            duration: dto.duration,
            imageAI: dto.imageAI,
            imageReal: dto.imageReal,
            address: dto.address,
            phone: dto.phone,
            website: dto.website,
            opening_hours: dto.opening_hours,
            latitude: dto.latitude,
            longitude: dto.longitude,
            category: dto.category,
            source: dto.source
        )

        try await itinerary.save(on: req.db)
        
        try await req.application.auditLogService.log(
            req: req,
            userID: payload.id,
            action: "save_advanced_itinerary",
            description: "Itinerario enriquecido guardado: \(dto.title)"
        )
        
        return .created
    }

    func list(req: Request) async throws -> [AdvancedItineraryDTO] {
        let payload = try req.auth.require(UserPayload.self)
        let itineraries = try await AdvancedItinerary.query(on: req.db)
            .filter(\.$user.$id == payload.id)
            .all()
        
        try await req.application.auditLogService.log(
            req: req,
            userID: payload.id,
            action: "list_advanced_itineraries",
            description: "Listado de itinerarios enriquecidos consultado"
        )

        return itineraries.map {
            AdvancedItineraryDTO(
                id: $0.id?.uuidString,
                title: $0.title,
                description: $0.description,
                duration: $0.duration,
                imageAI: $0.imageAI,
                imageReal: $0.imageReal,
                address: $0.address,
                phone: $0.phone,
                website: $0.website,
                opening_hours: $0.opening_hours,
                latitude: $0.latitude,
                longitude: $0.longitude,
                category: $0.category,
                source: $0.source
            )
        }
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(UserPayload.self)
        guard let idString = req.parameters.get("id"),
              let uuid = UUID(uuidString: idString),
              let itinerary = try await AdvancedItinerary.find(uuid, on: req.db),
              itinerary.$user.id == payload.id else {
            throw Abort(.notFound)
        }

        try await itinerary.delete(on: req.db)
        
        try await req.application.auditLogService.log(
            req: req,
            userID: payload.id,
            action: "delete_advanced_itinerary",
            description: "Itinerario enriquecido eliminado: \(uuid.uuidString)"
        )
        
        return .ok
    }
}
