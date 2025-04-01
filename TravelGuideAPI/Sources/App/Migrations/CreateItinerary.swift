//
//  CreateItinerary.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Fluent

struct CreateItinerary: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("itineraries")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("duration", .int, .required)
            .field("image", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("itineraries").delete()
    }
}
