// MARK: - AdsBannerController.swift

import Vapor
import JWT
import Foundation

struct AdsBannerController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let group = routes.grouped(JWTAuthenticatorMiddleware())
        group.post("ads", "banner", use: getAdBanner)
    }

    func getAdBanner(req: Request) async throws -> AdsResponseDTO {
        _ = try req.auth.require(UserPayload.self)

        struct AdRequest: Content {
            let latitude: Double
            let longitude: Double
        }

        _ = try req.content.decode(AdRequest.self)

        let publicPath = req.application.directory.publicDirectory + "ads/"
        let urlBase = "/ads/"

        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: publicPath)
            .filter { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") }

        guard let randomFile = files.randomElement() else {
            throw Abort(.notFound, reason: "No hay banners disponibles")
        }

        let adImageURL = urlBase + randomFile

        return AdsResponseDTO(
            id: nil,
            title: "",
            description: "",
            duration: 0,
            imageAI: "",
            imageReal: adImageURL,
            address: "",
            phone: "",
            website: "",
            opening_hours: "",
            latitude: 0.0,
            longitude: 0.0,
            category: "",
            source: ""
        )
    }
}
