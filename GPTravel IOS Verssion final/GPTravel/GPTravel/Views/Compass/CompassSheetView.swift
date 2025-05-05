import SwiftUI
import CoreLocation

struct CompassSheetView: View {
    let destination: CLLocationCoordinate2D
    @StateObject private var viewModel = CompassViewModel()
    @State private var randomBackground = "Fondo 1"

    var body: some View {
        ZStack {
            // Imagen de fondo
            Image(randomBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                CompassView(
                    bearing: viewModel.bearing,
                    distance: viewModel.distance
                )
            }
            .padding()
        }
        .onAppear {
            randomBackground = "playa\(Int.random(in: 1...6))"
            viewModel.startUpdates(to: destination)
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
        .presentationDetents([.medium])
    }
}

struct CompassView: View {
    let bearing: Double
    let distance: Double

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Círculo con fondo blanco y borde gris
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.gray)
                    .background(Circle().fill(Color.white)) // Fondo blanco
                    .frame(width: 200, height: 200)

                Arrow()
                    .fill(Color.red)
                    .frame(width: 30, height: 100)
                    .rotationEffect(.degrees(bearing))
            }
            .frame(width: 200, height: 200)

            // Texto de distancia en color blanco
            Text("Distancia al destino: \(formattedDistance())")
                .font(.headline)
                .foregroundColor(.white)
        }
    }

    private func formattedDistance() -> String {
        if distance > 1000 {
            return String(format: "%.2f km", distance / 1000)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.6, y: height))
        path.addLine(to: CGPoint(x: width * 0.4, y: height))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.6))
        path.addLine(to: CGPoint(x: 0, y: height * 0.6))
        path.closeSubpath()

        return path
    }
}
