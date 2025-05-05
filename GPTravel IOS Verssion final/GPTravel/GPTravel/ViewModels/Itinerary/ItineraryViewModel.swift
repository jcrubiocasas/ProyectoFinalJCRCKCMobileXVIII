//
//  ItineraryViewModel.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 14/4/25.
//

import SwiftUI
import Combine

@MainActor
class ItineraryViewModel: ObservableObject {
    // Publicado para la vista
    @Published var location: String = ""
    @Published var details: String = ""
    @Published var availableMinutes: String = ""
    @Published var itineraries: [Itinerary] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showResultsSheet: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let itineraryService: any ItineraryServiceProtocol
    private let authService: AuthService

    init(itineraryService: any ItineraryServiceProtocol = ItineraryService(), authService: AuthService = AuthService.shared) {
        self.itineraryService = itineraryService
        self.authService = authService
    }

    func searchItineraries() {
        // Validación
        guard !location.isEmpty, let minutes = Int(availableMinutes) else {
            self.errorMessage = "Introduce una ubicación y minutos válidos."
            return
        }
        
        // Cerrar teclado
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        // Resetear estado
        isLoading = true
        errorMessage = ""
        itineraries = []

        // Llamada a red
        itineraryService.fetchItineraries(for: location, details: details, availableHours: minutes, authService: authService)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ Error al recibir itinerarios: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] itineraries in
                print("✅ Itinerarios recibidos: \(itineraries)")
                self?.itineraries = itineraries
                self?.showResultsSheet = true
            }
            .store(in: &cancellables)
    }

    func addItinerary(_ itinerary: Itinerary) {
        print("➕ Añadiendo itinerario: \(itinerary.title)")
        // TODO: Persistir o enviar al backend
    }

    func discardItinerary(_ itinerary: Itinerary) {
        if let index = itineraries.firstIndex(where: { $0.id == itinerary.id }) {
            itineraries.remove(at: index)
        }
    }
}
