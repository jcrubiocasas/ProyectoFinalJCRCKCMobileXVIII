//
//  ItineraryPromptRequestDTO.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 27/3/25.
//

import Vapor

struct ItineraryPromptRequestDTO: Content {
    let destination: String
    let maxVisitTime: Int   // en minutos
    let maxResults: Int     // número de sitios sugeridos
}
