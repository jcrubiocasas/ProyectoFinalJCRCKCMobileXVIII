import Vapor

struct EmergencySessionResponseDTO: Content {
    let latitude: Double
    let longitude: Double
    let isActive: Bool
}
