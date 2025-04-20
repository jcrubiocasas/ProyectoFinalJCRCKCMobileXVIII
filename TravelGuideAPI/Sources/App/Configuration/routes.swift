import Fluent
import Vapor

func routes(_ app: Application) throws {
    // 🔒 Controladores que requieren autenticación JWT
    // Declara el entorno protegido por el middleware y JWT
    //let protected = app.grouped(JWTAuthenticatorMiddleware())
    let protected = app.grouped(UserPayload.authenticator())
    
    // Endpoint: me
    // Retorna datos del JWT sin hacer login
    try protected.register(collection: UserController())
    
    // Endpoint: ai/generate-itinerary
    // Podemos pedir la generacion de itinerarios a GPT e imagenes a DALL.E
    try protected.register(collection: ItineraryAIController())
    
    // Endpoint: itineraries/save Podemos salvar itinerario
    // Endpoint: itineraries/list Podemos listar itinerarios
    // Endpoint: itineraries/delete?id:UID de itinerario Podemos borrar itinerario
    try protected.register(collection: ItineraryController())
    
    // Endpoint: ai/generate-advanced-itinerary
    // Endpoint avanzado que combina recursos de Google Sites con la
    // creatividad de chatGPT
    // Endpoint experimental para vers si tiene un mejor rendimiento y
    // genera mas datos y satisfaccion del usuario
    
    try protected.register(collection: ItineraryAdvancedController())
    // Endpoint: advanced-itineraries/save Podemos salvar itinerario
    // Endpoint: advanced-itineraries/list Podemos listar itinerarios
    // Endpoint: advanced-itineraries/delete?id:UID de itinerario Podemos borrar itinerario
    try protected.register(collection: AdvancedItineraryController())
    
    // 🔓 Controladores sin autenticación
    // Endpoint: auth/register Podemos registrar usuario
    // Endpoint: auth/login Podemos hacer login que retorna token JWT
    try app.register(collection: AuthController())
}
