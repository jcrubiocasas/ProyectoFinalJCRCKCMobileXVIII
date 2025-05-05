import Foundation
import Combine

class MeViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var authService: AuthService?
    
    func setAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    func fetchUserDetails() {
        guard let authService = authService else {
            self.errorMessage = "AuthService no configurado"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        authService.getMe()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ Error fetching user details: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { userResponse in
                print("✅ Usuario recibido: \(userResponse)")
                self.fullName = userResponse.fullName
                self.email = userResponse.username
            }
            .store(in: &cancellables)
    }

    func deleteAccount() {
        guard let authService = authService else {
            self.errorMessage = "AuthService no configurado"
            return
        }

        isLoading = true
        errorMessage = ""

        authService.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ Error al eliminar cuenta: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in
                print("✅ Cuenta eliminada correctamente")
                authService.logout()
            }
            .store(in: &cancellables)
    }
}
