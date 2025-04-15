import Vapor
import Foundation

struct ChatGPTService {
    let client: any Client
    let gptToken: String
    let app: Application

    init(client: any Client, gptToken: String, app: Application) {
        self.client = client
        self.gptToken = gptToken
        self.app = app
    }

    func generateItinerary(from request: ItineraryPromptRequestDTO) async throws -> ItinerariesResponseDTO {
        let detailsPart: String
        if request.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            detailsPart = "" // No añadir nada si está vacío
        } else {
            detailsPart = "específicamente sitios que guarden relación con \"\(request.details)\", "
        }
        
        let maxVisitTime = max(request.maxVisitTime,60)

        let prompt = """
        Eres un experto guía de viajes y programador experto en formato JSON.

        Tu tarea es devolver EXCLUSIVAMENTE un array JSON válido.

        No añadas explicaciones, ni etiquetas, ni formato de Markdown. No añadas texto antes ni después del JSON.

        Petición:
        Quiero ir a \(request.destination), \(detailsPart) y dispongo de \(maxVisitTime) minutos para realizar turismo. 
        Recomiéndame \(request.maxResults) lugares interesantes para visitar.

        Formato de respuesta JSON requerido:
        [
          {
            "title": "Nombre del lugar",
            "description": "Descripción de unas 80 a 100 palabras del lugar",
            "duration": número de minutos estimados para la actividad (entre 10 y \(request.maxVisitTime)),
            "image": "URL temporal",
            "latitude": número decimal representando latitud GPS,
            "longitude": número decimal representando longitud GPS
          }
        ]
        """
        
        let payload = ChatPayload(
            model: "gpt-4o",
            messages: [.init(role: "user", content: prompt)],
            temperature: 0.7
        )

        let response = try await client.post(
            URI(string: "https://api.openai.com/v1/chat/completions")
        ) { req in
            try req.content.encode(payload, as: .json)
            req.headers.bearerAuthorization = .init(token: gptToken)
            req.headers.contentType = .json
        }

        let result = try response.content.decode(CompletionResponse.self)

        guard let rawJsonString = result.choices.first?.message.content else {
            throw Abort(.internalServerError, reason: "Respuesta malformada de GPT")
        }

        let cleanJsonString = sanitizeJSONString(rawJsonString)

        guard let jsonData = cleanJsonString.data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "No se pudo convertir la respuesta a datos JSON")
        }

        var itineraries = try JSONDecoder().decode([ItineraryDTO].self, from: jsonData)

        itineraries = try await itineraries.asyncMap { itinerary in
            var enriched = itinerary
            let id = UUID().uuidString
            enriched.id = id
            enriched.image = "/images/itineraries/\(id).png"

            Task.detached {
                await self.generateAndSaveImage(for: itinerary, with: id)
            }

            return enriched
        }

        return ItinerariesResponseDTO(itineraries: itineraries)
    }

    // MARK: - Helpers

    private func sanitizeJSONString(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func generateImageBase64(prompt: String) async throws -> String {
        struct ImageRequest: Content {
            let prompt: String
            let n: Int
            let size: String
            let response_format: String
        }

        struct ImageResponse: Content {
            struct ImageData: Content {
                let b64_json: String
            }
            let data: [ImageData]
        }

        let payload = ImageRequest(prompt: prompt, n: 1, size: "512x512", response_format: "b64_json")
        //let payload = ImageRequest(prompt: prompt, n: 1, size: "512x720", response_format: "b64_json")

        do {
            let response = try await client.post(
                URI(string: "https://api.openai.com/v1/images/generations")
            ) { req in
                try req.content.encode(payload, as: .json)
                req.headers.bearerAuthorization = .init(token: gptToken)
                req.headers.contentType = .json
            }

            let decoded = try response.content.decode(ImageResponse.self)
            guard let base64 = decoded.data.first?.b64_json else {
                throw Abort(.internalServerError, reason: "No se recibió imagen de DALL·E")
            }

            return base64
        } catch {
            print("⚠️ Error generando imagen con DALL·E: \(error)")
            return try loadDefaultImageBase64()
        }
    }

    private func loadDefaultImageBase64() throws -> String {
        let defaultImagePath = app.directory.publicDirectory + "default/itineraries/default.png"
        let url = URL(fileURLWithPath: defaultImagePath)
        let data = try Data(contentsOf: url)
        return data.base64EncodedString()
    }
    
    private func saveImageToDisk(base64: String, id: String) throws {
        guard let data = Data(base64Encoded: base64) else {
            throw Abort(.internalServerError, reason: "No se pudo decodificar la imagen base64")
        }

        let imagesFolder = app.directory.publicDirectory + "images/itineraries"
        try FileManager.default.createDirectory(atPath: imagesFolder, withIntermediateDirectories: true)

        let filePath = imagesFolder + "/\(id).png"
        try data.write(to: URL(fileURLWithPath: filePath))

        print("✅ Imagen guardada en disco: \(filePath)")
    }

    private func generateAndSaveImage(for itinerary: ItineraryDTO, with id: String) async {
        do {
            let dallePrompt = """
            Eres un experto en viajes y fotografía.
            Genera una imagen muy realista y atractiva, 
            para ilustrar un itinerario de viaje cuyo título es: \(itinerary.title) 
            y cuya descripción es: \(itinerary.description)
            """
            let base64 = try await generateImageBase64(prompt: dallePrompt)
            try saveImageToDisk(base64: base64, id: id)
        } catch {
            print("❌ Error generando imagen para \(id): \(error)")
        }
    }
}

// MARK: - Payload para la petición a ChatGPT

private struct ChatPayload: Content {
    struct ChatMessage: Content {
        let role: String
        let content: String
    }

    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

// MARK: - Estructura para la respuesta de OpenAI

private struct CompletionResponse: Content {
    struct Choice: Content {
        struct Message: Content {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - DTO para devolver itinerarios

struct ItinerariesResponseDTO: Content {
    let itineraries: [ItineraryDTO]
}
