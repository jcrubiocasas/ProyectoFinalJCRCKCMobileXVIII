import Foundation
import Alamofire

class EmergencyService {
    static let shared = EmergencyService()
    
    private init() {}
    
    func startEmergency(emergencyEmail: String, latitude: Double, longitude: Double, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(AuthService.shared.endpoint)/emergency/start"
        let parameters: [String: Any] = [
            "emergencyEmail": emergencyEmail,
            "latitude": latitude,
            "longitude": longitude
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
    
    func updateEmergency(latitude: Double, longitude: Double, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(AuthService.shared.endpoint)/emergency/update"
        let parameters: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
    
    func stopEmergency(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(AuthService.shared.endpoint)/emergency/stop"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
}
