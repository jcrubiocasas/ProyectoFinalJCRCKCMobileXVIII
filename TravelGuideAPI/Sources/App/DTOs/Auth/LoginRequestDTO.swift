//
//  LoginRequest.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 26/3/25.
//

import Vapor

struct LoginRequestDTO: Content {
    let username: String
    let password: String
}
