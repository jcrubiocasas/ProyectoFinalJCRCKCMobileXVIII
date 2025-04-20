//
//  AdvancedItinerary.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 16/4/25.
//

import Vapor
import Fluent

final class AdvancedItinerary: Model, Content, @unchecked Sendable {
    static let schema = "advanced_itineraries"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "title") var title: String
    @Field(key: "description") var description: String
    @Field(key: "duration") var duration: Int
    @Field(key: "imageAI") var imageAI: String
    @Field(key: "imageReal") var imageReal: String
    @Field(key: "address") var address: String
    @Field(key: "phone") var phone: String
    @Field(key: "website") var website: String
    @Field(key: "opening_hours") var opening_hours: String
    @Field(key: "latitude") var latitude: Double
    @Field(key: "longitude") var longitude: Double
    @Field(key: "category") var category: String
    @Field(key: "source") var source: String

    init() {}

    init(id: UUID? = nil, userID: UUID, title: String, description: String, duration: Int, imageAI: String, imageReal: String, address: String, phone: String, website: String, opening_hours: String, latitude: Double, longitude: Double, category: String, source: String) {
        self.id = id
        self.$user.id = userID
        self.title = title
        self.description = description
        self.duration = duration
        self.imageAI = imageAI
        self.imageReal = imageReal
        self.address = address
        self.phone = phone
        self.website = website
        self.opening_hours = opening_hours
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.source = source
    }
}
