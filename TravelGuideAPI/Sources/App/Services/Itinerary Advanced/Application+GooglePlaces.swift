//
//  Application+GooglePlaces.swift
//  TravelGuideAPI
//
//  Created by Juan Carlos Rubio Casas on 15/4/25.
//

import Vapor

extension Application {
    private struct GooglePlacesServiceKey: StorageKey {
        typealias Value = GooglePlacesService
    }

    var googlePlacesService: GooglePlacesService {
        get {
            guard let service = self.storage[GooglePlacesServiceKey.self] else {
                fatalError("❌ GooglePlacesService no ha sido configurado")
            }
            return service
        }
        set {
            self.storage[GooglePlacesServiceKey.self] = newValue
        }
    }
}
