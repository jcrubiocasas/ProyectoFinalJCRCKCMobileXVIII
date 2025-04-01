//
//  ItineraryAIController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor
import JWT

struct ItineraryAIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        //let group = routes.grouped("ai-itineraries")
        //group.post(use: generateItinerary)
        let group = routes.grouped("ai") // en lugar de "ai-itineraries"
        group.post("generate-itinerary", use: generateItinerary)
    }

    func generateItinerary(req: Request) async throws -> [ItineraryDTO] {
        // 📥 Log: Entrada a la función
        req.logger.info("➡️ Petición recibida en ItineraryAIController")

        // 🛡️ Autenticación del usuario
        let user = try req.auth.require(UserPayload.self)
        req.logger.info("🔐 Usuario autenticado: \(user.username)")

        // 🐞 DEBUG: imprimir el body crudo
        if let raw = req.body.string {
            req.logger.info("📦 Cuerpo recibido: \(raw)")
        } else {
            req.logger.warning("⚠️ No se pudo leer el cuerpo de la petición")
        }

        // 📄 Extrae los datos del prompt desde el cuerpo del request
        let promptDTO = try req.content.decode(ItineraryPromptRequestDTO.self)
        req.logger.info("📝 Prompt recibido para destino: \(promptDTO.destination), tiempo: \(promptDTO.maxVisitTime), número: \(promptDTO.maxResults)")

        // 🤖 Llama al servicio compartido registrado en Application
        let resultado = try await req.application.chatGPTService.generateItinerary(from: promptDTO)
        req.logger.info("✅ Itinerario generado con éxito. Lugares: \(resultado.count)")
        return resultado
    }
}
