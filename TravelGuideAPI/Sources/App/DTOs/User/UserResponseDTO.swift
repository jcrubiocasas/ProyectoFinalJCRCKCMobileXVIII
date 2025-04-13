//
//  UserResponseDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor

struct UserResponseDTO: Content {
    let id: UUID
    let username: String
    let fullName: String
    let isActive: Bool
}
