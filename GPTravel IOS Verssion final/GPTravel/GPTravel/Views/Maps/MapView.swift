
import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var authService: AuthService
    var itineraries: [AdvancedItinerary] = []
    var userLocation: CLLocationCoordinate2D? = nil

    @Binding var selectedItinerary: AdvancedItinerary?

    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion())
    @State private var route: MKRoute?

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(itineraries) { itinerary in
                Annotation(itinerary.title, coordinate: CLLocationCoordinate2D(latitude: itinerary.latitude, longitude: itinerary.longitude)) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(itinerary.title)
                            .font(.caption)
                    }
                }
            }

            if let route = route {
                MapPolyline(coordinates: route.polyline.coordinates)
                    .stroke(Color.blue, lineWidth: 4)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onAppear {
            if let userLocation = userLocation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
                fetchRoute()
            }
        }
        .onChange(of: selectedItinerary) { _, _ in
            fetchRoute()
        }
    }

    private func fetchRoute() {
        guard let from = userLocation,
              let to = selectedItinerary?.coordinate else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, error in
            if let route = response?.routes.first {
                self.route = route
            } else {
                print("❌ Error obteniendo ruta: \(error?.localizedDescription ?? "desconocido")")
            }
        }
    }
}

struct MapScreen: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var locationManager = LocationManager()
    @State private var selectedItinerary: AdvancedItinerary? = nil

    var body: some View {
        ZStack {
            if let userLocation = locationManager.location {
                MapView(itineraries: [], userLocation: userLocation, selectedItinerary: $selectedItinerary)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView("Obteniendo ubicación...")
            }
        }
        .navigationTitle("Mapa")
    }
}
#Preview {
    MapScreen().environmentObject(AuthService.shared)
}

