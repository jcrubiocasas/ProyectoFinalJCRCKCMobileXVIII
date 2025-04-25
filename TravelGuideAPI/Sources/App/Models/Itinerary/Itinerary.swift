//
//  Itinerary.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Fluent
import Vapor

final class Itinerary: Model, Content, @unchecked Sendable {
    static let schema = "itineraries"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "duration")
    var duration: Int // en minutos

    @Field(key: "image")
    var image: String

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    init() {}

    init(id: UUID? = nil,
         userID: UUID,
         title: String,
         description: String,
         duration: Int,
         image: String,
         latitude: Double,
         longitude: Double) {
        self.id = id
        self.$user.id = userID
        self.title = title
        self.description = description
        self.duration = duration
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }
}
