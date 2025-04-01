//
//  ItineraryDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 1/4/25.
//

import Vapor

struct ItineraryDTO: Content {
    var id: String? = nil
    let title: String
    let description: String
    let duration: Int
    var image: String
    let latitude: Double
    let longitude: Double
}
