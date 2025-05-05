import XCTVapor
import Fluent
@testable import App

final class AuthTests: XCTestCase {
    
    func testUserRegistrationAndLoginFlow() async throws {
        let app = try await Application.testable()
        //let tester = XCTApplicationTester(app) // ✅ uso correcto
        //let tester = app.testable()
        
        addTeardownBlock {
            try? await app.asyncShutdown() // ✅ shutdown limpio en async test
        }

        try await app.autoMigrate()

        // 1. Registro
        let registerData = RegisterRequestDTO(
            username: "test@example.com",
            password: "123456",
            fullName: "Test User"
        )

        try await app.test(HTTPMethod.POST, "/auth/register", beforeRequest: { req in
            try await req.content.encode(registerData)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, HTTPResponseStatus.created)
        })

        // 2. Activar usuario manualmente
        guard let user = try await User.query(on: app.db)
            .filter(\.$username == "test@example.com")
            .first()
        else {
            XCTFail("❌ Usuario no encontrado en base de datos tras el registro")
            return
        }

        user.isActive = true
        try await user.save(on: app.db)

        // 3. Login
        let loginData = LoginRequestDTO(
            username: "test@example.com",
            password: "123456"
        )

        try await app.test(HTTPMethod.POST, "/auth/login", beforeRequest: { req in
            try await req.content.encode(loginData)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, HTTPResponseStatus.ok)
            let token = try res.content.decode(TokenResponseDTO.self)
            XCTAssertFalse(token.token.isEmpty)
        })
    }
}
