//
//  ItineraryServiceProtocol.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 9/4/25.
//

import Foundation
import Combine

protocol ItineraryServiceProtocol: ObservableObject {
    func fetchItineraries(for location: String, details: String, availableHours: Int, authService: AuthService) -> AnyPublisher<[Itinerary], Error>
}
