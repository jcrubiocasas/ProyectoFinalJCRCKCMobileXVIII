import Fluent
import Vapor

func routes(_ app: Application) throws {
    /*
    let protected = app.grouped(JWTAuthenticatorMiddleware())
    try protected.register(collection: UserController())

    try app.routes.register(collection: AuthController())
    
    try app.grouped(JWTAuthenticatorMiddleware()).register(collection: ItineraryAIController())
    try app.routes.register(collection: AIController(chatService: app.chatGPTService))
    
    try app.grouped(JWTAuthenticatorMiddleware()).register(collection: ItineraryController())
    try app.routes.register(collection: ItineraryController())
     */
    // 🔒 Controladores que requieren autenticación JWT
    let protected = app.grouped(JWTAuthenticatorMiddleware())
    try protected.register(collection: UserController())
    try protected.register(collection: ItineraryController())
    try protected.register(collection: ItineraryAIController())

    // 🔓 Controladores sin autenticación
    try app.register(collection: AuthController())
    try app.register(collection: AIController(chatService: app.chatGPTService))
}
