//
//  AuthModels.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 9/4/25.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let fullName: String
}

struct TokenResponse: Codable {
    let token: String
}
