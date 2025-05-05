//
//  AdvancedItineraryServiceProtocol.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Combine

protocol AdvancedItineraryServiceProtocol {
    func fetchAdvancedItineraries(for location: String, details: String, availableMinutes: Int, authService: AuthService) -> AnyPublisher<[AdvancedItinerary], Error>
}
