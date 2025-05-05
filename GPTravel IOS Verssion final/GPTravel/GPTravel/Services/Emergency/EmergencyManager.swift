import Foundation
import CoreLocation
import Combine

@MainActor
class EmergencyManager: ObservableObject {
    static let shared = EmergencyManager()
    
    @Published var isEmergencyActive = false
    private var timer: Timer?
    private let locationManager = LocationManager()
    private var firstSend = true // ✅ Para saber si enviamos /start o /update
    
    private init() {}
    
    func startEmergency() {
        guard !isEmergencyActive else { return }
        isEmergencyActive = true
        firstSend = true
        sendCurrentLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.sendCurrentLocation()
        }
    }
    
    func stopEmergency() {
        guard isEmergencyActive else { return }
        isEmergencyActive = false
        timer?.invalidate()
        timer = nil
        sendStopEmergency()
    }
    
    private func sendCurrentLocation() {
        guard let location = locationManager.location else {
            print("⚠️ Ubicación no disponible para enviar emergencia")
            return
        }
        
        guard !AuthService.shared.token.isEmpty else {
            print("⚠️ No hay token disponible")
            return
        }
        let token = AuthService.shared.token
        
        let latitude = location.latitude
        let longitude = location.longitude
        let email = UserDefaults.standard.string(forKey: "emergencyEmail") ?? "noemail@domain.com"
        
        if firstSend {
            EmergencyService.shared.startEmergency(
                emergencyEmail: email,
                latitude: latitude,
                longitude: longitude,
                token: token
            ) { result in
                switch result {
                case .success:
                    print("✅ Emergencia iniciada correctamente")
                    self.firstSend = false
                case .failure(let error):
                    print("❌ Error iniciando emergencia: \(error.localizedDescription)")
                }
            }
        } else {
            EmergencyService.shared.updateEmergency(
                latitude: latitude,
                longitude: longitude,
                token: token
            ) { result in
                switch result {
                case .success:
                    print("📍 Actualización de ubicación enviada correctamente")
                case .failure(let error):
                    print("❌ Error enviando actualización de ubicación: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendStopEmergency() {
        guard !AuthService.shared.token.isEmpty else {
            print("⚠️ No hay token disponible")
            return
        }
        let token = AuthService.shared.token

        EmergencyService.shared.stopEmergency(token: token) { result in
            switch result {
            case .success:
                print("✅ Emergencia detenida correctamente")
            case .failure(let error):
                print("❌ Error deteniendo emergencia: \(error.localizedDescription)")
            }
        }
    }
}
