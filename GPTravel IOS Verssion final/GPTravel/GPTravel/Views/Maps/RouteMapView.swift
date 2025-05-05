import SwiftUI
import MapKit

struct RouteMapView: View {
    var origin: CLLocationCoordinate2D
    var destination: CLLocationCoordinate2D

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion())
    @State private var route: MKRoute?

    var body: some View {
        Map(position: $cameraPosition) {
            // Anotaciones para Origen y Destino
            Annotation("Tú", coordinate: origin) {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.largeTitle)
                }
            }

            Annotation("Destino", coordinate: destination) {
                VStack {
                    Image(systemName: "flag.circle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                }
            }

            // Dibujo de la ruta
            if let route = route {
                MapPolyline(route.polyline)
                    .stroke(Color.blue, lineWidth: 5)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onAppear {
            setupRegion()
            calculateRoute()
        }
    }

    private func setupRegion() {
        let centerLatitude = (origin.latitude + destination.latitude) / 2
        let centerLongitude = (origin.longitude + destination.longitude) / 2
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    private func calculateRoute() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        MKDirections(request: request).calculate { response, error in
            if let route = response?.routes.first {
                DispatchQueue.main.async {
                    self.route = route
                }
            } else {
                print("❌ Error calculando ruta: \(error?.localizedDescription ?? "desconocido")")
            }
        }
    }
}
