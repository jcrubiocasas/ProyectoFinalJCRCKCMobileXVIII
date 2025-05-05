
import Foundation

struct AdvancedItinerary: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let duration: Int
    let latitude: Double
    let longitude: Double
    let imageAI: String
    let imageReal: String?
    let address: String?
    let phone: String?
    let website: String?
    let opening_hours: String?
    let source: String?
    let category: String?
}

