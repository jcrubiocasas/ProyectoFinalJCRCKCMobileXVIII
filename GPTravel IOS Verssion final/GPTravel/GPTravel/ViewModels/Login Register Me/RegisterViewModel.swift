//
//  RegisterViewModel.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 13/4/25.
//

import Foundation
import Combine
import Alamofire

class RegisterViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = "" // ✅ Añadido para éxito

    private var cancellables = Set<AnyCancellable>()
    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
    }

    func register() {
        isLoading = true
        errorMessage = ""
        successMessage = "" // ✅ Limpiar mensaje de éxito al iniciar registro
        
        authService.register(fullName: fullName, username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    // Capturamos error específico de Alamofire
                    if let afError = error as? AFError {
                        if let responseCode = afError.responseCode {
                            if responseCode == 409 {
                                self.errorMessage = "El usuario ya existe. Intente iniciar sesión."
                            } else {
                                self.errorMessage = "Error de servidor (\(responseCode))."
                            }
                        } else {
                            self.errorMessage = afError.localizedDescription
                        }
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    print("❌ Error de registro: \(self.errorMessage)")
                case .finished:
                    break
                }
            } receiveValue: { _ in
                print("✅ Registro exitoso")
                self.successMessage = "¡Registro exitoso! 🎉" // ✅ Guardamos mensaje de éxito
            }
            .store(in: &cancellables)
    }
}
