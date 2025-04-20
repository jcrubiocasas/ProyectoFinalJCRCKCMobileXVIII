//
//  UserController.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor
import JWT

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let userRoutes = routes.grouped("me")
        userRoutes.get(use: me)
    }

    func me(req: Request) throws -> UserResponseDTO {
        let payload = try req.auth.require(UserPayload.self)
        
        Task {
            try? await req.application.auditLogService.log(
                req: req,
                userID: payload.id,
                action: "get_user_info",
                description: "Consulta de información del usuario"
            )
        }
        
        return UserResponseDTO(
            id: payload.id,
            username: payload.username,
            fullName: payload.fullName,
            isActive: payload.isActive
        )
    }
}
