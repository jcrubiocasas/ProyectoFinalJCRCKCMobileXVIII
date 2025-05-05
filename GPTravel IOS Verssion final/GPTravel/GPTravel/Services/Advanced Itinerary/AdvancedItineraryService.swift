//
//  AdvancedItineraryService.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Foundation
import Combine
import Alamofire

class AdvancedItineraryService: AdvancedItineraryServiceProtocol {
    
    func fetchAdvancedItineraries(for location: String, details: String, availableMinutes: Int, authService: AuthService) -> AnyPublisher<[AdvancedItinerary], Error> {
        
        let url = "\(authService.endpoint)/ai/generate-advanced-itinerary"
        
        let parameters: [String: Any] = [
            "destination": location,
            "details": details,
            "maxVisitTime": availableMinutes,
            "maxResults": 1
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authService.token)"
        ]
        
        return AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .publishDecodable(type: [AdvancedItinerary].self)
            .value()
            .mapError { $0 as Error } // ✅ Conversión del error
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
