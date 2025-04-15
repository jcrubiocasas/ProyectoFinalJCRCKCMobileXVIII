//
//  PromptType.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//
import Vapor

enum PromptType: String, Codable, CustomStringConvertible {
    case tourism
    case restaurants
    case events
    case nightlife
    case museums

    var description: String {
        switch self {
        case .tourism: return "Turismo"
        case .restaurants: return "Restaurantes"
        case .events: return "Eventos"
        case .nightlife: return "Vida Nocturna"
        case .museums: return "Museos"
        }
    }
}
