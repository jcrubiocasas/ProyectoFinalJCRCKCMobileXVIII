//
//  RegisterRequestDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor

struct RegisterRequestDTO: Content {
    let username: String     // Email
    let password: String
    let fullName: String
}
