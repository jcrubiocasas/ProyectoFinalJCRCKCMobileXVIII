import SwiftUI

struct HomeView: View {
    @State private var showSettings = false
    @State private var selectedTab = 0
    @State private var selectedItinerary: AdvancedItinerary? = nil
    @ObservedObject private var emergencyManager = EmergencyManager.shared
    @State private var emergencyAlertType: EmergencyAlertType? = nil

    var body: some View {
        ZStack {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    AdvancedItinerarySearchView()
                        .tabItem {
                            Label("Buscar", systemImage: "magnifyingglass")
                        }
                        .tag(0)

                    SavedItinerariesView()
                        .tabItem {
                            Label("Guardados", systemImage: "bookmark.fill")
                        }
                        .tag(1)

                    MapView(selectedItinerary: $selectedItinerary)
                        .tabItem {
                            Label("Mapa", systemImage: "map.fill")
                        }
                        .tag(2)
                }
                .accentColor(.red)
                .onAppear {
                    UITabBar.appearance().unselectedItemTintColor = UIColor.systemBlue
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(emergencyManager.isEmergencyActive ? .red : .blue)
                                .imageScale(.large)
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }

            // Zona secreta de 3 taps
            Color.clear
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 80)
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    handleEmergencyTap()
                }
                .ignoresSafeArea(edges: .top)
                .position(x: UIScreen.main.bounds.width * 0.4, y: 50)
        }
        .alert(item: $emergencyAlertType) { type in
            switch type {
            case .start:
                return Alert(
                    title: Text("🚨 Emergencia detectada"),
                    message: Text("¿Deseas iniciar envío de tu ubicación?"),
                    primaryButton: .default(Text("Sí")) {
                        EmergencyManager.shared.startEmergency()
                    },
                    secondaryButton: .cancel()
                )
            case .stop:
                return Alert(
                    title: Text("✅ Emergencia activa"),
                    message: Text("¿Deseas detener el envío de ubicación?"),
                    primaryButton: .default(Text("Sí")) {
                        EmergencyManager.shared.stopEmergency()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func handleEmergencyTap() {
        if emergencyManager.isEmergencyActive {
            emergencyAlertType = .stop
        } else {
            emergencyAlertType = .start
        }
    }
}

enum EmergencyAlertType: Identifiable {
    case start
    case stop

    var id: Int {
        switch self {
        case .start: return 1
        case .stop: return 2
        }
    }
}

#Preview {
    HomeView()
}

