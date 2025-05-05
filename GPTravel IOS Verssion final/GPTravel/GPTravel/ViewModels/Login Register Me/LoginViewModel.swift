import Foundation
import Combine
import SwiftData

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func login(context: ModelContext, completion: @escaping (Bool) -> Void) {
        authService.login(username: username, password: password, context: context) { success in
            if !success {
                self.errorMessage = "Error al iniciar sesión"
            }
            completion(success)
        }
        .sink(receiveCompletion: { result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }, receiveValue: { _ in })
        .store(in: &cancellables)
    }
}
