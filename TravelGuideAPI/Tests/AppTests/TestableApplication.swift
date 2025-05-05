import XCTVapor
import Foundation
@testable import App

extension Application {
    static func testable() async throws -> Application {
        // ✅ Cargar manualmente .env.testing
        try loadEnvFile(named: ".env.testing")

        let app = try await Application.make(.testing)
        try await configure(app)
        return app
    }

    private static func loadEnvFile(named fileName: String) throws {
        guard let url = Bundle(for: TestableApplicationMarker.self).url(forResource: fileName, withExtension: nil) else {
            throw Abort(.internalServerError, reason: "Missing test environment file: \(fileName)")
        }

        let contents = try String(contentsOf: url)
        let lines = contents
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }

        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            setenv(key, value, 1)
        }
    }
}

extension Application {
    func testable() -> Application {
        self
    }
}
