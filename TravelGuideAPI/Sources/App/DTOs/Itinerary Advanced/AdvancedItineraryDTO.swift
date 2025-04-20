//
//  AdvancedItineraryDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 17/4/25.
//

import Vapor

struct AdvancedItineraryDTO: Content {
    var id: String?
    let title: String
    let description: String
    let duration: Int
    let imageAI: String
    let imageReal: String
    let address: String
    let phone: String
    let website: String
    let opening_hours: String
    let latitude: Double
    let longitude: Double
    let category: String
    let source: String
}
