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
    func register(req: Request) async throws -> HTTPStatus {
        let data = try req.content.decode(RegisterRequestDTO.self)

        // Verifica si ya existe ese usuario
        if try await User.query(on: req.db)
            .filter(\.$username == data.username)
            .first() != nil {
            throw Abort(.conflict, reason: "El usuario ya existe")
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
        return .created
    }
    
    // Logica de login
    func login(req: Request) async throws -> TokenResponseDTO {
        let data = try req.content.decode(LoginRequestDTO.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$username == data.username)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Usuario o contraseña incorrectos")
        }

        let isPasswordCorrect = try Bcrypt.verify(data.password, created: user.passwordHash)
        guard isPasswordCorrect else {
            throw Abort(.unauthorized, reason: "Usuario o contraseña incorrectos")
        }

        // Firma JWT
        let payload = UserPayload(
            id: try user.requireID(),
            username: user.username,
            fullName: user.fullName,
            isActive: user.isActive
        )
        
        let token = try req.jwt.sign(payload)

        return TokenResponseDTO(token: token)
    }
    
    
}
