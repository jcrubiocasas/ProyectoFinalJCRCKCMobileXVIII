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
    /*
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(JWTAuthenticatorMiddleware())
        group.post("itineraries", "save", use: saveItinerary)
        group.get("itineraries", "list", use: listItineraries)
        group.delete("itineraries", "delete", ":id", use: deleteItinerary)
    }
    */
    func boot(routes: any RoutesBuilder) throws {
        routes.post("itineraries", "save", use: saveItinerary)
        routes.get("itineraries", "list", use: listItineraries)
        routes.delete("itineraries", "delete", ":id", use: deleteItinerary)
    }

    // POST /itineraries/save
    func saveItinerary(req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(UserPayload.self)
        let dto = try req.content.decode(ItineraryDTO.self)
        
        let token = req.headers.bearerAuthorization?.token ?? "NO TOKEN"
        req.logger.info("🔑 TOKEN RECIBIDO: \(token)")
        let itinerary = Itinerary(
            userID: payload.id,
            title: dto.title,
            description: dto.description,
            duration: dto.duration,
            image: dto.image,
            latitude: dto.latitude,
            longitude: dto.longitude
        )

        try await itinerary.save(on: req.db)
        req.logger.info("✅ Itinerario guardado con éxito: \(payload.id)")
        return .created
    }

    // GET /itineraries/list
    func listItineraries(req: Request) async throws -> [ItineraryDTO] {
        let payload = try req.auth.require(UserPayload.self)

        let itineraries = try await Itinerary.query(on: req.db)
            .filter(\.$user.$id == payload.id)
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
        let payload = try req.auth.require(UserPayload.self)

        guard let idString = req.parameters.get("id"),
              let uuid = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "ID inválido")
        }

        guard let itinerary = try await Itinerary.find(uuid, on: req.db),
              itinerary.$user.id == payload.id else {
            throw Abort(.notFound, reason: "Itinerario no encontrado")
        }

        // Ruta completa al archivo de imagen
        let filename = "\(itinerary.id!.uuidString).png"
        let imagePath = req.application.directory.publicDirectory + "images/itineraries/" + filename

        // Eliminar el archivo del disco si existe
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: imagePath) {
            try fileManager.removeItem(atPath: imagePath)
            req.logger.info("🗑️ Imagen eliminada: \(filename)")
        } else {
            req.logger.warning("⚠️ Imagen no encontrada para eliminar: \(filename)")
        }

        try await itinerary.delete(on: req.db)
        return .ok
    }
}
