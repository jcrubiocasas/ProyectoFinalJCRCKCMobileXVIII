import SwiftUI
import SwiftData

@main
struct GPTravelApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var itineraryService = ItineraryService()
    @StateObject private var locationService = LocationService()
    @StateObject private var advancedViewModel = AdvancedItineraryViewModel()

    init() {
        // No se necesita inicialización de Google Maps
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authService)
                .environmentObject(itineraryService)
                .environmentObject(locationService)
                .environmentObject(advancedViewModel)
        }
        .modelContainer(for: [SavedItinerary.self])
    }
}
