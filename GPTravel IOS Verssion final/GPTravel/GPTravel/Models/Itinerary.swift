//
//  Itinerary.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 9/4/25.
//

import Foundation

struct Itinerary: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let duration: Int // duración en horas
    let latitude: Double
    let longitude: Double
    let image: String
}
