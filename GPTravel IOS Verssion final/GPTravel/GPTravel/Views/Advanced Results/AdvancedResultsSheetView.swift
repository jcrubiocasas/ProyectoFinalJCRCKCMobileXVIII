import SwiftUI
import CoreLocation
import SDWebImageSwiftUI

enum SheetMode {
    case search
    case saved
    case ads
}

struct IdentifiableCoordinate: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: IdentifiableCoordinate, rhs: IdentifiableCoordinate) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

struct AdvancedResultsSheetView: View {
    var itineraries: [AdvancedItinerary]
    var authService: AuthService
    var mode: SheetMode

    var onSave: ((AdvancedItinerary) -> Void)? = nil
    var onDiscard: (() -> Void)? = nil
    var onCompass: ((AdvancedItinerary) -> Void)? = nil
    var onDelete: ((AdvancedItinerary) -> Void)? = nil

    @State private var selectedDestination: IdentifiableCoordinate?
    @State private var showMapWithRoute = false
    @State private var currentDestination: CLLocationCoordinate2D?
    @State private var currentItinerary: AdvancedItinerary?
    @State private var randomBackground = "Fondo 1"
    @StateObject private var locationManager = LocationManager()

    @State private var showNavigationOptions = false // Para manejar el alert de navegación
    @State private var showDeleteConfirmation = false // Para manejar el alert de eliminación
    @State private var showCompassSheet = false // Para manejar el alert de eliminación


    var body: some View {
            NavigationStack {
                ZStack {
                    Image(randomBackground)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    ScrollView {
                        itineraryListView
                            .padding()
                    }
                }
                .navigationTitle(itineraries.first?.title ?? "Resultado")
                .actionSheet(isPresented: $showNavigationOptions) {
                    ActionSheet(
                        title: Text("Selecciona la opción de navegación"),
                        buttons: [
                            .default(Text("Navegar con Mapas de Apple")) {
                                openInAppleMaps(destination: currentDestination!)
                            },
                            .default(Text("Navegar con Google Maps")) {
                                openInGoogleMaps(destination: currentDestination!)
                            },
                            .default(Text("Navegar con Waze")) {
                                openInWaze(destination: currentDestination!)
                            },
                            .default(Text("Navegar con GPTravel")) {
                                showMapWithRoute = true
                            },
                            .cancel()
                        ]
                    )
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("¿Estás seguro de eliminar este itinerario?"),
                        primaryButton: .destructive(Text("Eliminar")) {
                            if let itineraryToDelete = currentItinerary {
                                onDelete?(itineraryToDelete) // Eliminar el itinerario seleccionado
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .sheet(isPresented: $showMapWithRoute) {
                    VStack {
                        if let userLocation = locationManager.location, let destination = currentDestination {
                            RouteMapContainerView(origin: userLocation, destination: destination)
                        } else {
                            VStack {
                                ProgressView()
                                Text("Esperando ubicación...")
                            }
                            .padding()
                        }
                    }
                }
                .sheet(item: $selectedDestination) { wrapper in
                    CompassSheetView(destination: wrapper.coordinate)
                }
                
            }
            .onAppear {
                randomBackground = "playa\(Int.random(in: 1...6))"
            }
        }

    @ViewBuilder
    private var itineraryListView: some View {
        VStack(spacing: 16) {
            ForEach(itineraries) { itinerary in
                AdvancedItineraryCardView(
                    itinerary: itinerary,
                    imageBaseURL: authService.endpoint
                )

                if mode == .search {
                    searchButtons(for: itinerary)
                } else if mode == .saved {
                    savedButtons(for: itinerary)
                } else if mode == .ads {
                    adsButtons(for: itinerary)
                }
            }
        }
    }

    @ViewBuilder
    private func searchButtons(for itinerary: AdvancedItinerary) -> some View {
        HStack(spacing: 12) {
            Button("✅ Guardar") {
                onSave?(itinerary)
            }
            .tint(.green)
            
            Button("🗑 Descartar") {
                onDiscard?()
            }
            .tint(.red)
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func savedButtons(for itinerary: AdvancedItinerary) -> some View {
        HStack(spacing: 12) {
            Button("🧭 Brújula") {
                selectedDestination = IdentifiableCoordinate(coordinate: itinerary.coordinate)
                showCompassSheet = true
            }

            Button("📍 Navegar") {
                currentDestination = itinerary.coordinate
                showNavigationOptions = true
            }

            Button("🗑 Eliminar") {
                currentItinerary = itinerary
                showDeleteConfirmation = true
            }
            .tint(.red)
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func adsButtons(for itinerary: AdvancedItinerary) -> some View {
        HStack(spacing: 12) {
            Button("🧭 Brújula") {
                selectedDestination = IdentifiableCoordinate(coordinate: itinerary.coordinate)
            }
            Button("📍 Navegar") {
                currentDestination = itinerary.coordinate
                showNavigationOptions = true
            }
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
    }

    private func openInAppleMaps(destination: CLLocationCoordinate2D) {
        if let url = URL(string: "https://maps.apple.com/?daddr=\(destination.latitude),\(destination.longitude)") {
            UIApplication.shared.open(url)
        }
    }

    private func openInGoogleMaps(destination: CLLocationCoordinate2D) {
        if let url = URL(string: "https://www.google.com/maps?q=\(destination.latitude),\(destination.longitude)") {
            UIApplication.shared.open(url)
        }
    }

    private func openInWaze(destination: CLLocationCoordinate2D) {
        if let url = URL(string: "waze://?ll=\(destination.latitude),\(destination.longitude)&navigate=yes") {
            UIApplication.shared.open(url)
        }
    }
}

extension AdvancedItinerary {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}



/*
import SwiftUI
import CoreLocation
import SDWebImageSwiftUI

enum SheetMode {
    case search
    case saved
    case ads
}

struct IdentifiableCoordinate: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: IdentifiableCoordinate, rhs: IdentifiableCoordinate) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

struct AdvancedResultsSheetView: View {
    var itineraries: [AdvancedItinerary]
    var authService: AuthService
    var mode: SheetMode

    var onSave: ((AdvancedItinerary) -> Void)? = nil
    var onDiscard: (() -> Void)? = nil
    var onCompass: ((AdvancedItinerary) -> Void)? = nil
    var onDelete: ((AdvancedItinerary) -> Void)? = nil

    @State private var selectedDestination: IdentifiableCoordinate?
    @State private var showMapWithRoute = false
    //State private var userLocation: CLLocationCoordinate2D?
    @StateObject private var locationManager = LocationManager()
    @State private var currentDestination: CLLocationCoordinate2D?
    @State private var randomBackground = "Fondo 1"

    var body: some View {
        NavigationStack {
            ZStack {
                Image(randomBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ScrollView {
                    itineraryListView
                        .padding()
                }
            }
            .navigationTitle(itineraries.first?.title ?? "Resultado")
            .sheet(item: $selectedDestination) { wrapper in
                CompassSheetView(destination: wrapper.coordinate)
            }
            .sheet(isPresented: $showMapWithRoute) {
                VStack {
                    if let userLocation = locationManager.location, let destination = currentDestination {
                        Text("userLocation: \(userLocation.latitude), \(userLocation.longitude)")
                        Text("destination: \(destination.latitude), \(destination.longitude)")
                        //RouteMapView(origin: userLocation,destination: destination)
                        RouteMapContainerView(origin: userLocation, destination: destination)
                    } else {
                        VStack {
                            ProgressView()
                            Text("Esperando ubicación...")
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            randomBackground = "playa\(Int.random(in: 1...6))"
            
        }
    }

    @ViewBuilder
    private var itineraryListView: some View {
        VStack(spacing: 16) {
            ForEach(itineraries) { itinerary in
                AdvancedItineraryCardView(
                    itinerary: itinerary,
                    imageBaseURL: authService.endpoint
                )

                if mode == .search {
                    searchButtons(for: itinerary)
                } else if mode == .saved {
                    savedButtons(for: itinerary)
                } else if mode == .ads {
                    adsButtons(for: itinerary)
                }
            }
        }
    }

    @ViewBuilder
    private func searchButtons(for itinerary: AdvancedItinerary) -> some View {
        HStack(spacing: 12) {
            Button("✅ Guardar") {
                onSave?(itinerary)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, minHeight: 44)

            Button("🗑 Descartar") {
                onDiscard?()
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
    }

    @ViewBuilder
    private func savedButtons(for itinerary: AdvancedItinerary) -> some View {
        HStack(spacing: 12) {
            Button("🧭 Brújula") {
                selectedDestination = IdentifiableCoordinate(coordinate: itinerary.coordinate)
            }

            Button("📍 Navegar") {
                print("🌍 Pulsado botón Navegar")
                if let userLocation = locationManager.location {
                    print("📍 userLocation listo: \(userLocation.latitude), \(userLocation.longitude)")
                } else {
                    print("❌ userLocation es nil")
                }
                print("🗺️ itinerary.coordinate: \(itinerary.coordinate.latitude), \(itinerary.coordinate.longitude)")
                
                currentDestination = itinerary.coordinate
                
                DispatchQueue.main.async {
                    print("📦 currentDestination asignado: \(String(describing: currentDestination))")
                    showMapWithRoute = true
                }
            }
            
            Button("🗑 Eliminar") {
                onDelete?(itinerary)
            }
            .tint(.red)
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func adsButtons(for itinerary: AdvancedItinerary) -> some View {
        HStack(spacing: 12) {
            Button("🧭 Brújula") {
                selectedDestination = IdentifiableCoordinate(coordinate: itinerary.coordinate)
            }
            Button("📍 Navegar") {
                print("🌍 Pulsado botón Navegar")
                if let userLocation = locationManager.location {
                    print("📍 userLocation listo: \(userLocation.latitude), \(userLocation.longitude)")
                } else {
                    print("❌ userLocation es nil")
                }
                print("🗺️ itinerary.coordinate: \(itinerary.coordinate.latitude), \(itinerary.coordinate.longitude)")
                
                currentDestination = itinerary.coordinate
                
                DispatchQueue.main.async {
                    print("📦 currentDestination asignado: \(String(describing: currentDestination))")
                    showMapWithRoute = true
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
    }

    
}

extension AdvancedItinerary {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
*/
