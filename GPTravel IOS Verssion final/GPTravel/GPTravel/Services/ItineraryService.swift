import Foundation
import Combine
import Alamofire

class ItineraryService: ItineraryServiceProtocol, ObservableObject {
    func fetchItineraries(for location: String, details: String, availableHours: Int, authService: AuthService) -> AnyPublisher<[Itinerary], Error> {
        let url = "\(authService.endpoint)/ai/generate-itinerary"
        let parameters: [String: Any] = [
            "destination": location,
            "details": details,
            "maxVisitTime": availableHours,
            "maxResults": 1
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authService.token)",
            "Content-Type": "application/json"
        ]

        return AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .publishDecodable(type: [Itinerary].self)
            .value()
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
