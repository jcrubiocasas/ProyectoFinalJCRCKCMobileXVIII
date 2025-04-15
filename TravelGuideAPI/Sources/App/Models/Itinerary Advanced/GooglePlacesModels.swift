//
//  GooglePlacesModels.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Vapor

// MARK: - Respuestas crudas de la API de Google

struct GoogleTextSearchResponse: Content {
    let results: [GoogleTextResult]
}

struct GoogleTextResult: Content {
    let name: String
    let place_id: String
}

struct GooglePlaceDetailsResponse: Content {
    let result: GooglePlaceDetailsRaw
}

struct GooglePlaceDetailsRaw: Content {
    let name: String?
    let formatted_address: String?
    let geometry: GoogleGeometry?
    let photos: [GooglePhoto]?
    let formatted_phone_number: String?
    let website: String?
    let opening_hours: GoogleOpeningHours?
}

struct GoogleGeometry: Content {
    let location: GoogleLatLon
}

struct GoogleLatLon: Content {
    let lat: Double
    let lng: Double
}

struct GooglePhoto: Content {
    let photo_reference: String
}

struct GoogleOpeningHours: Content {
    let weekday_text: [String]?
}

// MARK: - Modelo limpio para uso en el frontend

struct GooglePlaceDetails: Content {
    let imageUrl: String?
    let address: String?
    let website: String?
    let phone: String?
    let openingHours: String?

    static func from(api: GooglePlaceDetailsRaw, apiKey: String) -> GooglePlaceDetails {
        let photoReference = api.photos?.first?.photo_reference ?? ""
        let imageUrl = !photoReference.isEmpty
            ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
            : nil

        return GooglePlaceDetails(
            imageUrl: imageUrl,
            address: api.formatted_address,
            website: api.website,
            phone: api.formatted_phone_number,
            openingHours: api.opening_hours?.weekday_text?.joined(separator: "\n")
        )
    }
}
