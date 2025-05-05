import SwiftUI
import LocalAuthentication
import SwiftData

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var randomBackground = "Fondo 1"
    @EnvironmentObject var authService: AuthService
    @Environment(\.modelContext) private var context
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled = false
    @AppStorage("isSimpleBackgroundEnabled") private var isSimpleBackgroundEnabled = false

    var body: some View {
        if isActive {
            ContentView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    if isSimpleBackgroundEnabled {
                        Color.white
                            .ignoresSafeArea()
                    } else {
                        Image(randomBackground)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            //.edgesIgnoringSafeArea(.all)
                    }
                    
                    Image("GPTravel_Logo_Recolor")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width / 2,
                                  y: geometry.size.height * 0.2) // posición 2 de 5
                        .opacity(isActive ? 0 : 1)
                        .scaleEffect(isActive ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5), value: isActive)
                }
                .onAppear {
                    randomBackground = "playa\(Int.random(in: 1...6))"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if authService.isAuthenticated {
                            if isFaceIDEnabled {
                                authService.authenticateWithBiometrics { success in
                                    if success {
                                        syncAndNavigate()
                                    } else {
                                        authService.logout()
                                        withAnimation {
                                            isActive = true
                                        }
                                    }
                                }
                            } else {
                                syncAndNavigate()
                            }
                        } else {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func syncAndNavigate() {
        let viewModel = AdvancedItineraryViewModel()
        viewModel.syncLocalWithBackend(context: context)
        withAnimation {
            isActive = true
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: SavedItinerary.self)
        return SplashScreenView()
            .environmentObject(AuthService.shared)
            .modelContainer(container)
    } catch {
        return Text("❌ Error cargando el modelo de datos")
    }
}
