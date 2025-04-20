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
        authRoutes.get("activate", use: activateUser)
        
        // 🔐 Ruta protegida por JWT
        let tokenProtected = authRoutes.grouped(JWTAuthenticatorMiddleware())
        tokenProtected.delete("delete", use: deleteAccount)
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
                isActive: false
            )
            
            try await user.save(on: req.db)
            
            // 🔐 Generar token de activación
            let activationToken = req.application.securityTokenService
                .generateActivationToken(datosAdicionales: user.username)

            // 📧 Enviar correo
            try await req.application.mailService.sendActivationEmail(
                to: user.username,
                withToken: activationToken,
                on: req
            )
            
            // Registro auditoria
            try await req.application.auditLogService.log(
                req: req,
                userID: try user.requireID(),
                action: "register",
                description: "Usuario registrado correctamente"
            )

            let response = RegisterResponseDTO(
                message: "Usuario registrado correctamente. Revisa tu correo para activar la cuenta."
            )
            return try await response.encodeResponse(status: .created, for: req)

        } catch {
            let response = RegisterResponseDTO(message: "Error interno del servidor")
            return try await response.encodeResponse(status: .internalServerError, for: req)
        }
    }
    
    // Endpoint de activación de cuenta desde el email
    func activateUser(req: Request) async throws -> String {
        guard let token = req.query[String.self, at: "token"] else {
            throw Abort(.badRequest, reason: "Token no proporcionado")
        }

        // ✅ Extraer username del token
        let username = req.application.securityTokenService
            .extractInfoFromToken(token: token)

        guard let username = username else {
            throw Abort(.unauthorized, reason: "Token inválido o expirado")
        }

        // Buscar usuario
        guard let user = try await User.query(on: req.db)
            .filter(\.$username == username)
            .first()
        else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        if user.isActive {
            return "✅ El usuario ya estaba activado"
        }

        // Activar y guardar
        guard let id = user.id,
              let refreshedUser = try await User.find(id, on: req.db) else {
            throw Abort(.internalServerError, reason: "Usuario inválido o sin ID")
        }

        refreshedUser.isActive = true
        try await refreshedUser.save(on: req.db)

        let updatedUser = try await User.find(id, on: req.db)
        print("📊 Estado actualizado: \(updatedUser?.isActive ?? false)")
        
        // Registro auditoria
        try await req.application.auditLogService.log(
            req: req,
            userID: id,
            action: "activate",
            description: "Cuenta activada mediante enlace de correo"
        )

        return "✅ Cuenta activada correctamente"
    }
    
    // Logica de login
    func login(req: Request) async throws -> TokenResponseDTO {
        let data = try req.content.decode(LoginRequestDTO.self)
        let expiration = ExpirationClaim(value: .init(timeIntervalSinceNow: 604800)) // 1 SEMANA = 604800 // 1 DIA = 86400 // 1 HORA = 3600 segundos
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
        
        if !user.isActive {
            // 🔐 Generar nuevo token de activación
            let activationToken = req.application.securityTokenService
                .generateActivationToken(datosAdicionales: user.username)

            // 📧 Reenviar correo de activación
            try await req.application.mailService.sendActivationEmail(
                to: user.username,
                withToken: activationToken,
                on: req
            )

            throw Abort(.unauthorized, reason: "La cuenta no está activada. Te hemos reenviado un nuevo correo de activación.")
        }
        
        // Registro auditoria
        try await req.application.auditLogService.log(
            req: req,
            userID: try user.requireID(),
            action: "login",
            description: "Inicio de sesión exitoso"
        )
        
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
    
    // MARK: - Baja de cuenta
    func deleteAccount(req: Request) async throws -> String {
        let payload = try req.auth.require(UserPayload.self)

        guard let user = try await User.find(payload.id, on: req.db) else {
            throw Abort(.notFound, reason: "Usuario no encontrado")
        }

        // Eliminar itinerarios normales
        try await Itinerary.query(on: req.db)
            .filter(\.$user.$id == payload.id)
            .delete()

        // Eliminar itinerarios avanzados si existen
        try? await AdvancedItinerary.query(on: req.db)
            .filter(\.$user.$id == payload.id)
            .delete()

        // Eliminar usuario
        try await user.delete(on: req.db)
        
        // Registro auditoria
        try await req.application.auditLogService.log(
            req: req,
            userID: payload.id,
            action: "delete_account",
            description: "Cuenta eliminada por el usuario"
        )

        return "🗑️ Cuenta eliminada correctamente"
    }
}
