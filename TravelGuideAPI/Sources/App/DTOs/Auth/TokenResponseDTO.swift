//
//  TokenDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 26/3/25.
//

import Vapor
import JWT

struct TokenResponseDTO: Content {
    let token: String
}

struct UserPayload: JWTPayload, Authenticatable {
    let id: UUID
    let username: String
    let fullName: String
    let isActive: Bool
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
