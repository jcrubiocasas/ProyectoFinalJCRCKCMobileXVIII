import Vapor
import JWT

struct ItineraryAIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.grouped("ai").post("generate-itinerary", use: generateItinerary)
    }

    func generateItinerary(req: Request) async throws -> [ItineraryDTO] {
        req.logger.info("➡️ Petición recibida en ItineraryAIController")

        let user = try req.auth.require(UserPayload.self)
        req.logger.info("🔐 Usuario autenticado: \(user.username)")

        if let raw = req.body.string {
            req.logger.info("📦 Cuerpo recibido: \(raw)")
        } else {
            req.logger.warning("⚠️ No se pudo leer el cuerpo de la petición")
        }

        let promptDTO = try req.content.decode(ItineraryPromptRequestDTO.self)
        req.logger.info("📝 Prompt recibido para destino: \(promptDTO.destination), \(promptDTO.details), tiempo: \(promptDTO.maxVisitTime), número: \(promptDTO.maxResults)")

        let result = try await req.application.chatGPTService.generateItinerary(from: promptDTO)
        req.logger.info("✅ Itinerario generado con éxito. Lugares: \(result.itineraries.count)")

        return result.itineraries
    }
}
