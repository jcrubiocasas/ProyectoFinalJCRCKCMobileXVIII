//
//  User.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 26/3/25.
//

import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "passwordHash")
    var passwordHash: String

    @Field(key: "fullName")
    var fullName: String

    @Field(key: "isActive")
    var isActive: Bool

    init() {}

    init(username: String, passwordHash: String, fullName: String, isActive: Bool) {
        self.username = username
        self.passwordHash = passwordHash
        self.fullName = fullName
        self.isActive = isActive
    }
}
