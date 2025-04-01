//
//  ItineraryController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor
import JWT
import Foundation
import Fluent

struct ItineraryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(JWTAuthenticatorMiddleware())
        group.post("itineraries", "save", use: saveItinerary)
        group.get("itineraries", "list", use: listItineraries)
        group.delete("itineraries", "delete", ":id", use: deleteItinerary)
    }

    // POST /itineraries/save
    func saveItinerary(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let dto = try req.content.decode(ItineraryDTO.self)
        
        let token = req.headers.bearerAuthorization?.token ?? "NO TOKEN"
        req.logger.info("🔑 TOKEN RECIBIDO: \(token)")
        print("🔑 TOKEN RECIBIDO: \(token)")


        let itinerary = Itinerary(
            userID: try user.requireID(),
            title: dto.title,
            description: dto.description,
            duration: dto.duration,
            image: dto.image,
            latitude: dto.latitude,
            longitude: dto.longitude
        )

        try await itinerary.save(on: req.db)
        return .created
    }

    // GET /itineraries/list
    func listItineraries(req: Request) async throws -> [ItineraryDTO] {
        let user = try req.auth.require(User.self)
        let itineraries = try await Itinerary.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .all()

        return itineraries.map {
            ItineraryDTO(
                id: $0.id?.uuidString,
                title: $0.title,
                description: $0.description,
                duration: $0.duration,
                image: $0.image,
                latitude: $0.latitude,
                longitude: $0.longitude
            )
        }
    }

    // DELETE /itineraries/delete/:id
    func deleteItinerary(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        guard let idString = req.parameters.get("id"),
              let uuid = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        guard let itinerary = try await Itinerary.find(uuid, on: req.db),
              itinerary.$user.id == user.id else {
            throw Abort(.notFound, reason: "Itinerario no encontrado")
        }

        try await itinerary.delete(on: req.db)
        return .ok
    }
}
