import Foundation
import Combine
import Alamofire
import SwiftData

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var token: String = ""
    @Published var endpoint: String {
        didSet {
            UserDefaults.standard.set(endpoint, forKey: "endpoint")
        }
    }
    @Published var autoLoginEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(autoLoginEnabled, forKey: "autologin")
        }
    }

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.endpoint = UserDefaults.standard.string(forKey: "endpoint") ?? "http://dev.equinsaparking.com:10605"
        self.autoLoginEnabled = UserDefaults.standard.bool(forKey: "autologin")
        
        // 🔐 Autologin desde Keychain
        if let data = KeychainHelper.shared.read(service: "gptravel", account: "authToken"),
           let savedToken = String(data: data, encoding: .utf8),
           !savedToken.isEmpty {
            self.token = savedToken
            self.isAuthenticated = true
        }
    }

    // ✅ FIXED: faltaba el `{` al comienzo del cuerpo de la función
    func login(username: String, password: String, context: ModelContext, completion: @escaping (Bool) -> Void) -> AnyPublisher<Bool, Error> {
        let url = "\(endpoint)/auth/login"
        let parameters = LoginRequest(username: username, password: password)
        
        return AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
            .validate()
            .publishDecodable(type: TokenResponse.self)
            .value()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { tokenResponse in
                self.token = tokenResponse.token
                self.isAuthenticated = true
                
                // 🧠 Sincronizar itinerarios del usuario tras login
                self.fetchSavedItineraries(context: context) {
                    completion(true)
                }
                
                if self.autoLoginEnabled {
                    if let data = tokenResponse.token.data(using: .utf8) {
                        KeychainHelper.shared.save(data, service: "gptravel", account: "authToken")
                    }
                }
            })
            .map { _ in true }
            .mapError { error in
                if let afError = error.asAFError, afError.responseCode == 401 {
                    return AuthError.invalidCredentials
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func fetchSavedItineraries(context: ModelContext, completion: @escaping () -> Void) {
        let url = "\(endpoint)/advanced-itineraries/list"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(self.token)"]

        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [AdvancedItinerary].self) { response in
                switch response.result {
                case .success(let itineraries):
                    let repo = SavedItineraryRepository(context: context)
                    repo.deleteAll()
                    repo.saveAll(from: itineraries)
                    completion()
                case .failure:
                    completion()
                }
            }
    }
    
    func register(fullName: String, username: String, password: String) -> AnyPublisher<RegisterResponseDTO, Error> {
        guard let url = URL(string: "\(endpoint)/auth/register") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let registerBody = RegisterRequest(username: username, password: password, fullName: fullName)
        
        return AF.request(url,
                          method: .post,
                          parameters: registerBody,
                          encoder: JSONParameterEncoder.default)
            .validate()
            .publishDecodable(type: RegisterResponseDTO.self)
            .value()
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getMe() -> AnyPublisher<UserResponse, Error> {
        let url = "\(endpoint)/me"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        return AF.request(url, method: .get, headers: headers)
            .validate()
            .publishDecodable(type: UserResponse.self)
            .value()
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func logout() {
        token = ""
        fullName = ""
        email = ""
        isAuthenticated = false
        KeychainHelper.shared.delete(service: "gptravel", account: "authToken")
    }

    func setAuthenticated(_ value: Bool) {
        isAuthenticated = value
    }

    func restoreSessionFromKeychain() {
        if let data = KeychainHelper.shared.read(service: "gptravel", account: "authToken"),
           let savedToken = String(data: data, encoding: .utf8),
           !savedToken.isEmpty {
            self.token = savedToken
            self.isAuthenticated = true
            print("✅ Sesión restaurada desde Keychain")
        } else {
            print("⚠️ No se encontró token válido en Keychain")
        }
    }
    
    func deleteAccount() -> AnyPublisher<Void, Error> {
        let url = "\(endpoint)/auth/delete"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return AF.request(url, method: .delete, headers: headers)
            .validate()
            .publishData()
            .tryMap { result in
                guard result.response?.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidRegistration
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Usuario o contraseña inválidos."
        case .invalidRegistration:
            return "Registro inválido. Verifique los campos."
        }
    }
}
