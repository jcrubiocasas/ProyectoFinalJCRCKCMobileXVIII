import Vapor
import Fluent

struct EmergencySessionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(JWTAuthenticatorMiddleware())
        group.post("emergency", "start", use: startEmergency)
        group.post("emergency", "update", use: updateEmergency)
        group.post("emergency", "stop", use: stopEmergency)
        
        // Endpoint público de tracking (sin JWT)
        routes.get("emergency", "track", ":token", use: trackEmergency)
        routes.get("emergency", "location", ":token", use: locationEmergency)
    }
    
    // MARK: - Iniciar Emergencia
    func startEmergency(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserPayload.self)
        
        struct StartRequest: Content {
            let emergencyEmail: String
            let latitude: Double
            let longitude: Double
        }
        
        let body = try req.content.decode(StartRequest.self)
        
        if try await EmergencySession.query(on: req.db)
            .filter(\.$user.$id == user.id)
            .filter(\.$isActive == true)
            .first() != nil
        {
            req.logger.warning("⚠️ Emergencia ya activa para usuario \(user.username)")
            return .conflict
        }
        
        let token = UUID().uuidString
        let session = EmergencySession(
            userID: user.id,
            emergencyEmail: body.emergencyEmail,
            latitude: body.latitude,
            longitude: body.longitude,
            token: token
        )
        
        try await session.save(on: req.db)
        
        let baseURL = Environment.get("EMERGENCY_PUBLIC_BASEURL") ?? "http://localhost:8080"
        let trackURL = "\(baseURL)/emergency/track/\(token)"
        
        let message = """
        🚨 ¡Alerta de emergencia!

        El usuario \(user.username) ha activado el modo emergencia.

        Puedes seguir su ubicación en tiempo real aquí:
        \(trackURL)
        """
        
        try await req.application.mailService.sendEmergencyEmail(
            to: body.emergencyEmail,
            subject: "Alerta de emergencia de \(user.username)",
            body: message,
            on: req
        )
        
        req.logger.info("✅ Emergencia iniciada y correo enviado a \(body.emergencyEmail)")
        return .created
    }
    
    // MARK: - Actualizar posición
    func updateEmergency(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserPayload.self)
        
        struct UpdateRequest: Content {
            let latitude: Double
            let longitude: Double
        }
        
        let body = try req.content.decode(UpdateRequest.self)
        
        guard let session = try await EmergencySession.query(on: req.db)
            .filter(\.$user.$id == user.id)
            .filter(\.$isActive == true)
            .first()
        else {
            throw Abort(.notFound, reason: "No hay emergencia activa")
        }
        
        session.latitude = body.latitude
        session.longitude = body.longitude
        try await session.save(on: req.db)
        
        req.logger.info("🛰️ Emergencia actualizada para usuario \(user.username)")
        return .ok
    }
    
    // MARK: - Detener Emergencia
    func stopEmergency(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(UserPayload.self)
        
        guard let session = try await EmergencySession.query(on: req.db)
            .filter(\.$user.$id == user.id)
            .filter(\.$isActive == true)
            .first()
        else {
            throw Abort(.notFound, reason: "No hay emergencia activa")
        }
        
        session.isActive = false
        try await session.save(on: req.db)
        
        req.logger.info("🛑 Emergencia finalizada para usuario \(user.username)")
        return .ok
    }
    
    // MARK: - Tracking Público
    func trackEmergency(req: Request) async throws -> Response {
        guard let token = req.parameters.get("token"),
              let session = try await EmergencySession.query(on: req.db)
                .filter(\.$token == token)
                .filter(\.$isActive == true)
                .first()
        else {
            // Redirigir a página de error si no hay sesión activa
            return req.redirect(to: "/emergency/error.html")
        }
        
        let htmlURL = "/emergency/EmergencyTracker.html?token=\(token)"
        return req.redirect(to: htmlURL)
    }
    
    // MARK: - Nueva API para obtener la localización en tiempo real
    func locationEmergency(req: Request) async throws -> EmergencySessionResponseDTO {
        guard let token = req.parameters.get("token"),
              let session = try await EmergencySession.query(on: req.db)
                .filter(\.$token == token)
                .filter(\.$isActive == true)
                .first()
        else {
            throw Abort(.notFound, reason: "No se encontró la emergencia o ya finalizó")
        }
        
        return EmergencySessionResponseDTO(
            latitude: session.latitude,
            longitude: session.longitude,
            isActive: session.isActive
        )
    }
}
