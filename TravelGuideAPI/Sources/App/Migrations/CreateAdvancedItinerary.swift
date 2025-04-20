//
//  CreateAdvancedItinerary.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 17/4/25.
//

import Fluent

struct CreateAdvancedItinerary: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("advanced_itineraries")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("duration", .int, .required)
            .field("imageAI", .string, .required)
            .field("imageReal", .string, .required)
            .field("address", .string, .required)
            .field("phone", .string, .required)
            .field("website", .string, .required)
            .field("opening_hours", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("category", .string, .required)
            .field("source", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("advanced_itineraries").delete()
    }
}
