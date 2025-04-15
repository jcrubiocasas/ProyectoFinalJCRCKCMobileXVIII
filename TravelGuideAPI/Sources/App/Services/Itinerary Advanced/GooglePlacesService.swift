//
//  GooglePlacesService.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Vapor

struct GooglePlacesService {
    let client: any Client
    let googleApiKey: String

    init(client: any Client, googleApiKey: String) {
        self.client = client
        self.googleApiKey = googleApiKey
    }

    /// Busca un lugar por nombre y coordenadas aproximadas
    func findPlace(named name: String, near lat: Double, lon: Double) async throws -> GooglePlaceDetails? {
        // 1. Buscar lugar por texto y localización
        let encodedQuery = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let textSearchURL = URI(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedQuery)&location=\(lat),\(lon)&radius=3000&key=\(googleApiKey)")

        let textResponse = try await client.get(textSearchURL)
        let textData = try textResponse.content.decode(GoogleTextSearchResponse.self)

        guard let firstResult = textData.results.first else {
            return nil // No encontrado
        }

        // 2. Detalles con place_id
        return try await getDetails(for: firstResult.place_id)
    }

    /// Consulta la API de Place Details
    func getDetails(for placeID: String) async throws -> GooglePlaceDetails {
        let fields = "name,formatted_address,geometry,photos,formatted_phone_number,website,opening_hours"
        let detailsURL = URI(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(googleApiKey)")

        let response = try await client.get(detailsURL)
        let detailsData = try response.content.decode(GooglePlaceDetailsResponse.self)
        return GooglePlaceDetails.from(api: detailsData.result, apiKey: googleApiKey)
    }

    /// Genera una URL de imagen desde un photo_reference
    func buildPhotoURL(reference: String, maxWidth: Int = 800) -> String {
        return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(reference)&key=\(googleApiKey)"
    }
}
