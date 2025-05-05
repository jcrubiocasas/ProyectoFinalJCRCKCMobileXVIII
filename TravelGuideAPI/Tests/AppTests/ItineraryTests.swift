import XCTVapor
import XCTest
@testable import App


func testGenerateBasicItinerary() async throws {
    let app = try await Application.testable()
    let token = try await loginTestUser() // Usa una función reutilizable que haga login
    
    let input = ItineraryPromptRequestDTO(destination: "Madrid", details: "", maxVisitTime: 240, maxResults: 1)

    try await app.test(HTTPMethod.POST, "/ai/generate-itinerary", beforeRequest: { req async throws in
        req.headers.bearerAuthorization = BearerAuthorization(token: token)
        try req.content.encode(input)
    }, afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let result = try res.content.decode([ItineraryDTO].self)
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result[0].description.isEmpty)
    })
}
