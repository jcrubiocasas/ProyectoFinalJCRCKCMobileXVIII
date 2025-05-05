import SwiftUI
import CoreLocation

struct RouteMapContainerView: View {
    let origin: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) { // Cambié .topTrailing a .topLeading
            RouteMapView(
                origin: origin,
                destination: destination
            )
            .ignoresSafeArea() // <-- El mapa ocupa toda la pantalla

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .background(Circle().fill(Color.black.opacity(0.3)).frame(width: 50, height: 50))
            }
            .padding()
            .padding(.top, -5) // Mantengo el padding superior para evitar que el botón se solape con la parte superior
        }
        .background(Color.white)
    }
}

// Preview para la vista RouteMapContainerView
struct RouteMapContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RouteMapContainerView(
            origin: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038), // Ejemplo de origen
            destination: CLLocationCoordinate2D(latitude: 40.4237, longitude: -3.7003) // Ejemplo de destino
        )
    }
}




/*
 
import SwiftUI
import CoreLocation

struct RouteMapContainerView: View {
    let origin: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RouteMapView(
                origin: origin,
                destination: destination
            )
            .ignoresSafeArea() // <-- el mapa ocupa toda la pantalla

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .background(Circle().fill(Color.black.opacity(0.3)).frame(width: 50, height: 50))
            }
            .padding()
            .padding(.top, 10)
        }
        .background(Color.white)
    }
}
*/
