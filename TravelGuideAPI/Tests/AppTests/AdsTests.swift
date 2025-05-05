import XCTVapor
import XCTest
@testable import App

final class AdsTests: XCTestCase {
    
    func testBannerAd() async throws {
        let app = try await Application.testable()
        
        let token = try await loginTestUser()
        
        let payload = ["latitude": 40.4, "longitude": -3.7]

        try await app.test(HTTPMethod.POST, "/ads/banner", beforeRequest: { req async throws in
            req.headers.bearerAuthorization = BearerAuthorization(token: token)
                try req.content.encode(payload)
            },
            afterResponse: { res async throws in
                XCTAssertEqual(res.status, .ok)
                _ = try res.content.decode(AdsResponseDTO.self)
            })
    }
}
