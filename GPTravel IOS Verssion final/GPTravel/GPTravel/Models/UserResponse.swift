//
//  UserResponse.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 9/4/25.
//

import Foundation

struct UserResponse: Codable {
    let id: String
    let fullName: String
    let username: String
    let isActive: Bool
}
