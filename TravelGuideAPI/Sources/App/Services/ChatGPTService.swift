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

    func generateItinerary(from request: ItineraryPromptRequestDTO) async throws -> [ItineraryDTO] {
        let prompt = """
        Eres un experto guía de viajes. 
        Necesito que me ayudes a buscar informacion de sitios para hacer turismo, segun los siguientes paramentros:
        Quiero ir a \(request.destination) \(request.details), dispongo de \(request.maxVisitTime) minutos para realizar turismo. 
        Recomiéndame \(request.maxResults) lugares interesantes para visitar.

        Devuélveme SOLO un array JSON con los siguientes campos por lugar. No añadas texto antes o después del array. Todos los campos deben ser reales y coherentes.
        [
          {
            "title": "Nombre del lugar",
            "description": "Descripción de unas 80 a 100 palabras del lugar",
            "duration": 60,
            "image": "URL temporal",
            "latitude": 40.4168,
            "longitude": -3.7038
          }
        ]
        """

        let payload = ChatPayload(
            model: "gpt-3.5-turbo",
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

        struct CompletionResponse: Content {
            struct Choice: Content {
                struct Message: Content {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let result = try response.content.decode(CompletionResponse.self)

        guard let jsonString = result.choices.first?.message.content,
              let jsonData = jsonString.data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "Respuesta malformada de GPT")
        }

        var itineraries = try JSONDecoder().decode([ItineraryDTO].self, from: jsonData)

        itineraries = try await itineraries.asyncMap { itinerary in
            var enriched = itinerary
            let id = UUID().uuidString
            enriched.id = id
            enriched.image = "/images/itineraries/\(id).png"

            // Lanzar generación de imagen en segundo plano
            Task.detached {
                do {
                    let dallePrompt = """
                    Eres un experto en viajes y fotografia.
                    Genera una imagen atractiva lo mas realista posible, 
                    para ilustrar un itinerario de viaje, 
                    cuyo titulo descriptivo es: \(itinerary.title) y 
                    cuya descripcion se ajuste lo mas posible a: \(itinerary.description)
                    """
                    let base64 = try await generateImageBase64(prompt: dallePrompt)
                    try saveImageToDisk(base64: base64, id: id)
                } catch {
                    print("❌ Error generando imagen para \(id): \(error)")
                }
            }

            return enriched
        }

        return itineraries
    }
    /*
    func generateItinerary(from request: ItineraryPromptRequestDTO) async throws -> [ItineraryResponseDTO] {
        let prompt = """
        Eres un experto guía de viajes. Quiero ir a \(request.destination), dispongo de \(request.maxVisitTime) minutos para realizar turismo. 
        Recomiéndame \(request.maxResults) lugares interesantes para visitar.

        Devuélveme SOLO un array JSON con los siguientes campos por lugar. No añadas texto antes o después del array. Todos los campos deben ser reales y coherentes.
        [
          {
            "title": "Nombre del lugar",
            "description": "Descripción de unas 50 a 80 palabras del lugar",
            "duration": 60,
            "image": "URL temporal",
            "latitude": 40.4168,
            "longitude": -3.7038
          }
        ]
        """

        let payload = ChatPayload(
            model: "gpt-3.5-turbo",
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

        struct CompletionResponse: Content {
            struct Choice: Content {
                struct Message: Content {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let result = try response.content.decode(CompletionResponse.self)

        guard let jsonString = result.choices.first?.message.content,
              let jsonData = jsonString.data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "Respuesta malformada de GPT")
        }

        var itineraries = try JSONDecoder().decode([ItineraryResponseDTO].self, from: jsonData)

        itineraries = try await itineraries.asyncMap { itinerary in
            var enriched = itinerary
            let id = UUID().uuidString
            //let hostname = app.http.server.configuration.hostname
            //let port = app.http.server.configuration.port
            //let imageURL = "http://\(hostname):\(port)/images/itineraries/\(id).png"
            //enriched.image = imageURL
            enriched.id = id
            enriched.image = "/images/itineraries/\(id).png" // Ruta relativa

            Task.detached {
                do {
                    let prompt = "\(itinerary.title): \(itinerary.description)"
                    let base64 = try await generateImageBase64(prompt: prompt)
                    try saveImageToDisk(base64: base64, id: id)
                } catch {
                    print("❌ Error generando imagen para \(id): \(error)")
                }
            }
            return enriched
        }

        return itineraries
    }
    */
    
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
    }
    
    // Salvamos imagen generada por DALL.E a disco a la caprpeta
    // Public/images/itineraries para disponer de un repositorio de
    // imagenes libres de derechos de autor y sin dependencias externas
    // licencias o suscripciones de uso.
    private func saveImageToDisk(base64: String, id: String) throws {
        guard let data = Data(base64Encoded: base64) else {
            throw Abort(.internalServerError, reason: "No se pudo decodificar la imagen base64")
        }

        // Construir ruta de guardado basada en el directorio público de Vapor
        let imagesFolder = app.directory.publicDirectory + "images/itineraries"
        
        // Crear el directorio si no existe
        try FileManager.default.createDirectory(atPath: imagesFolder, withIntermediateDirectories: true)

        // Ruta final del archivo
        let filePath = imagesFolder + "/\(id).png"

        try data.write(to: URL(fileURLWithPath: filePath))
        print("✅ Imagen guardada en disco: \(filePath)")
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




/*
// V2
 
import Vapor
import Foundation

struct ChatGPTService {
    let client: any Client
    let gptToken: String

    init(client: any Client, gptToken: String) {
        self.client = client
        self.gptToken = gptToken
    }

    func generateItinerary(from request: ItineraryPromptRequestDTO) async throws -> [ItineraryResponseDTO] {
        let prompt = """
        Eres un experto guía de viajes. Quiero ir a \(request.destination), dispongo de \(request.maxVisitTime) minutos para realizar turismo. 
        Recomiéndame \(request.maxResults) lugares interesantes para visitar.

        Devuélveme SOLO un array JSON con los siguientes campos por lugar. No añadas texto antes o después del array. Todos los campos deben ser reales y coherentes.
        [
          {
            "title": "Nombre del lugar",
            "description": "Descripción de unas 50 a 80 palabras del lugar",
            "duration": 60,
            "image": "URL temporal",
            "latitude": 40.4168,
            "longitude": -3.7038
          }
        ]
        """

        let payload = ChatPayload(
            model: "gpt-3.5-turbo",
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

        let raw = response.body?.getString(at: 0, length: response.body?.readableBytes ?? 0)
        print("\n🧠 Respuesta cruda de OpenAI:\n\(raw ?? "")\n")

        struct CompletionResponse: Content {
            struct Choice: Content {
                struct Message: Content {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let result = try response.content.decode(CompletionResponse.self)

        guard let jsonString = result.choices.first?.message.content,
              let jsonData = jsonString.data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "Respuesta malformada de GPT")
        }

        var itineraries = try JSONDecoder().decode([ItineraryResponseDTO].self, from: jsonData)

        // 🔁 Enriquecer con imagen DALL·E codificada en base64
        itineraries = try await itineraries.asyncMap { itinerary in
            var enriched = itinerary
            let dallePrompt = "\(itinerary.title): \(itinerary.description)"
            enriched.image = try await generateImageBase64(prompt: dallePrompt)
            return enriched
        }

        return itineraries
    }

    // 🔄 Genera imagen con DALL·E y devuelve el contenido en base64
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

        let requestPayload = ImageRequest(
            prompt: prompt,
            n: 1,
            size: "512x512",
            response_format: "b64_json"
        )

        let response = try await client.post(
            URI(string: "https://api.openai.com/v1/images/generations")
        ) { req in
            try req.content.encode(requestPayload, as: .json)
            req.headers.bearerAuthorization = .init(token: gptToken)
            req.headers.contentType = .json
        }

        let decoded = try response.content.decode(ImageResponse.self)
        guard let base64 = decoded.data.first?.b64_json else {
            throw Abort(.internalServerError, reason: "No se recibió imagen de DALL·E")
        }

        return "data:image/png;base64,\(base64)"
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
*/


/*
// V1
import Vapor
import Foundation

// MARK: - Servicio de generación de itinerarios con OpenAI
struct ChatGPTService {
    let client: any Client
    let gptToken: String
    let unsplashToken: String

    init(client: any Client, gptToken: String, unsplashToken: String) {
        self.client = client
        self.gptToken = gptToken
        self.unsplashToken = unsplashToken
    }

    func generateItinerary(from request: ItineraryPromptRequestDTO) async throws -> [ItineraryResponseDTO] {
        let prompt = """
        Eres un experto guía de viajes. Quiero ir a \(request.destination), dispongo de \(request.maxVisitTime) minutos para realizar turismo. 
        Recomiéndame \(request.maxResults) lugares interesantes para visitar.

        Devuélveme SOLO un array JSON con los siguientes campos por lugar. No añadas texto antes o después del array. Todos los campos deben ser reales y coherentes.
        [
          {
            "title": "Nombre del lugar",
            "description": "Descripción de unas 50 a 80 palabras del lugar",
            "duration": 60,
            "image": "https://source.unsplash.com/featured/?landmark,\(request.destination)",
            "latitude": 40.4168,
            "longitude": -3.7038
          }
        ]
        """

        let payload = ChatPayload(
            model: "gpt-3.5-turbo",
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

        if let body = response.body,
           let raw = body.getString(at: 0, length: body.readableBytes) {
            print("\n\u{1F9E0} Respuesta cruda de OpenAI:\n\(raw)\n")
        }

        struct CompletionResponse: Content {
            struct Choice: Content {
                struct Message: Content {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let result = try response.content.decode(CompletionResponse.self)

        guard let jsonString = result.choices.first?.message.content else {
            throw Abort(.internalServerError, reason: "GPT no devolvió ningún contenido")
        }

        print("\n\u{1F4DD} JSON string interpretado desde OpenAI:\n\(jsonString)\n")

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "No se pudo convertir la respuesta a datos JSON")
        }

        let itineraries = try JSONDecoder().decode([ItineraryResponseDTO].self, from: jsonData)

        let enriched = try await itineraries.asyncMap { itinerary -> ItineraryResponseDTO in
            var enrichedItinerary = itinerary
            let image = try await fetchImage(for: itinerary.title)
            enrichedItinerary.image = image ?? "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"
            return enrichedItinerary
        }

        return enriched
    }

    private func fetchImage(for query: String) async throws -> String {
        // 1. Codificar el query
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return fallbackSourceImage(for: query)
        }

        // 2. Intentar la búsqueda con la API oficial de Unsplash
        let searchURL = URI(string: "https://api.unsplash.com/search/photos?query=\(encodedQuery)&per_page=1")

        let response = try await client.get(searchURL) { req in
            req.headers.add(name: .authorization, value: "Client-ID \(unsplashToken)")
        }

        struct SearchResponse: Decodable {
            struct Photo: Decodable {
                struct Urls: Decodable {
                    let regular: String
                }
                let urls: Urls
            }
            let results: [Photo]
        }

        let decoded = try response.content.decode(SearchResponse.self)

        // 3. Verificamos que hay una imagen válida
        if let imageUrl = decoded.results.first?.urls.regular {
            let check = try await client.get(URI(string: imageUrl))
            if check.status == .ok, check.headers.contentType?.description.contains("image") == true {
                return imageUrl
            }
        }

        // 4. Si falla, usar fallback dinámico
        return fallbackSourceImage(for: query)
    }

    private func fallbackSourceImage(for query: String) -> String {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "travel"
        return "https://source.unsplash.com/1600x900/?\(encoded)"
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
*/
