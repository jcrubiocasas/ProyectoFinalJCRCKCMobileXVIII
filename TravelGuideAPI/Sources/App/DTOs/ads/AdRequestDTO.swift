import Vapor

// DTO para recibir latitud y longitud
struct AdRequestDTO: Content {
    let latitude: Double
    let longitude: Double
}
