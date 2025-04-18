//
//  AuthController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 26/3/25.
//

import Vapor
import Fluent
import JWT

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        authRoutes.post("register", use: register)
        authRoutes.post("login", use: login)
    }
    
    // Logica del registro de usuario nuevo
    func register(req: Request) async throws -> Response {
        do {
            let data = try req.content.decode(RegisterRequestDTO.self)
            
            // Verificar si ya existe
            if try await User.query(on: req.db)
                .filter(\.$username == data.username)
                .first() != nil {
                // Aquí ya no hacemos throw directamente
                let response = RegisterResponseDTO(message: "El usuario ya existe")
                return try await response.encodeResponse(status: .conflict, for: req)
            }
            
            // Encriptar password
            let passwordHash = try Bcrypt.hash(data.password)
            
            // Crear nuevo usuario
            let user = User(
                username: data.username,
                passwordHash: passwordHash,
                fullName: data.fullName,
                isActive: true
            )
            
            try await user.save(on: req.db)
            
            // Devolver éxito
            let response = RegisterResponseDTO(message: "Usuario registrado correctamente")
            return try await response.encodeResponse(status: .created, for: req)
            
        } catch {
            // Error inesperado
            let response = RegisterResponseDTO(message: "Error interno del servidor")
            return try await response.encodeResponse(status: .internalServerError, for: req)
        }
    }
    
    // Logica de login
    func login(req: Request) async throws -> TokenResponseDTO {
        let data = try req.content.decode(LoginRequestDTO.self)
        let expiration = ExpirationClaim(value: .init(timeIntervalSinceNow: 86400))
        // 1 SEMANA = 604800
        // 1 DIA = 86400
        // 1 HORA = 3600 segundos
        guard let user = try await User.query(on: req.db)
            .filter(\.$username == data.username)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Usuario incorrecto")
        }

        let isPasswordCorrect = try Bcrypt.verify(data.password, created: user.passwordHash)
        guard isPasswordCorrect else {
            throw Abort(.unauthorized, reason: "Contraseña incorrecta")
        }

        // Firma JWT
        let payload = UserPayload(
            id: try user.requireID(),
            username: user.username,
            fullName: user.fullName,
            isActive: user.isActive,
            exp: expiration
        )
        
        let token = try req.jwt.sign(payload)

        return TokenResponseDTO(token: token)
    }
    
    
}
