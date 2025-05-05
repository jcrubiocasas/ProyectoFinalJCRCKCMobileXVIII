import XCTVapor
import XCTest
@testable import App


func testEmergencySend() async throws {
    let app = try await Application.testable()
    let token = try await loginTestUser()

    let body = EmergencySessionResponseDTO(
        latitude: 41.38,
        longitude: 2.17,
        isActive: true
    )

    try await app.test(HTTPMethod.POST, "/emergency/send", beforeRequest: { req async throws in
        req.headers.bearerAuthorization = BearerAuthorization(token: token)
        try req.content.encode(body)
    }, afterResponse: { res in
        XCTAssertEqual(res.status, HTTPResponseStatus.ok)
    })
}
