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
