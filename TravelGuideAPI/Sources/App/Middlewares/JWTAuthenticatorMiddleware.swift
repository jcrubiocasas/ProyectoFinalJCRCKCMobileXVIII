//
//  JWTAuthenticatorMiddleware.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor
import JWT

struct JWTAuthenticatorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Token JWT requerido")
        }

        do {
            let payload = try request.jwt.verify(authHeader.token, as: UserPayload.self)
            request.auth.login(payload)
        } catch {
            throw Abort(.unauthorized, reason: "Token JWT inválido")
        }

        return try await next.respond(to: request)
    }
}
