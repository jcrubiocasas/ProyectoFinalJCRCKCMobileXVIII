//  AdsDTO.swift
//  GPTravel

import Foundation

struct AdsDTO: Codable {
    /// ID local generado automáticamente (no viene del backend)
    var id: String = UUID().uuidString

    var title: String = ""
    var description: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var imageReal: String? = nil
    var address: String? = nil
    var phone: String? = nil
    var website: String? = nil
    var opening_hours: String? = nil
    var category: String? = nil
    var source: String? = nil
    var duration: Int = 0

    /// Conversión al modelo principal de itinerario
    func toAdvancedItinerary() -> AdvancedItinerary {
        AdvancedItinerary(
            id: id,
            title: title,
            description: description,
            duration: duration,
            latitude: latitude,
            longitude: longitude,
            imageAI: "", // evita error por nil
            imageReal: imageReal,
            address: address,
            phone: phone,
            website: website,
            opening_hours: opening_hours,
            source: source,
            category: category
        )
    }

    // ⚠️ Evita que se intente decodificar `id` desde el backend
    private enum CodingKeys: String, CodingKey {
        case title, description, latitude, longitude,
             imageReal, address, phone, website,
             opening_hours, category, source, duration
    }
}
