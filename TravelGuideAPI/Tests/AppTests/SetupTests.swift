import XCTVapor
import XCTest
@testable import App


func loginTestUser() async throws -> String {
    let app = try await Application.testable()
    let email = "test+login@example.com"
    let password = "123456"

    // Registra si no existe
    // Registra si no existe
    if try await User.query(on: app.db).filter(\.$username, .equal, email).first() == nil {
        let user = User(
            username: email,
            passwordHash: try Bcrypt.hash(password),
            fullName: "Test",
            isActive: true
        )
        try await user.save(on: app.db)
    }

    var token = ""
    try await app.test(HTTPMethod.POST, "/auth/login", beforeRequest: { req async throws in
        try req.content.encode(["email": email, "password": password])
    }, afterResponse: { res in
        let response = try res.content.decode(TokenResponseDTO.self)
        token = response.token
    })
    return token
}
