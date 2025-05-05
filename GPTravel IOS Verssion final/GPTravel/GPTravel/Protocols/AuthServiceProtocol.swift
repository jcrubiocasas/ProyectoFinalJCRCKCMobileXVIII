//
//  AuthServiceProtocol.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 9/4/25.
//

import Foundation
import Combine
import SwiftData

protocol AuthServiceProtocol: ObservableObject {
    var isAuthenticated: Bool { get }
    func login(username: String, password: String, context: ModelContext, completion: @escaping (Bool) -> Void) -> AnyPublisher<Bool, Error>
    func register(fullName: String, username: String, password: String) -> AnyPublisher<RegisterResponseDTO, Error>
    func logout()
    func getMe() -> AnyPublisher<UserResponse, Error>
    func setAuthenticated(_ value: Bool)
    func fetchSavedItineraries(context: ModelContext, completion: @escaping () -> Void)
}
