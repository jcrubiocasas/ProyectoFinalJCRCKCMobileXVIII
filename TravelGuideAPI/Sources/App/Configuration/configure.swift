import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

public func configure(_ app: Application) async throws {
    
    // 🌐 Permitir conexiones externas
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
    // 🛢 Lectura de los datos de configuracion de las variables de
    // entorno para la configuración de la base de datos PostgreSQL
    let postgresConfig = SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "travelguide",
        tls: .disable
    )
    app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    // 🔐 Configuración del firmante JWT
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "default-secret"))
    
    
    // 🧠 Token OpenAI y registro del servicio GPT
    // ✅ Lee token OpenAI de las variables de entorno
    guard let openAIToken = Environment.get("OPENAI_KEY") else {
        fatalError("❌ Falta OPENAI_KEY en el entorno")
    }
    // ✅ Lee Unsplash de las variables de entorno
    //guard let unsplashToken = Environment.get("UNSPLASH_KEY") else {
    //    fatalError("❌ Falta UNSPLASH_KEY en el entorno")
    //}
    
    // ✅ Inyecta el servicio con ambas claves
    app.chatGPTService = ChatGPTService(
        client: app.client,
        gptToken: openAIToken,
        app: app
    )
    
    
    // 🚫 Middleware JWT NO se aplica globalmente
    // app.middleware.use(JWTAuthenticatorMiddleware()) // ← Esto se aplica solo en rutas privadas
    // ✅ Sirve archivos desde Public/
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // 🛠 Migrations
    app.migrations.add(CreateUser()) // Tabla de usuarios
    app.migrations.add(CreateItinerary()) // Tabla de itinerarios
    // 📌 Rutas
    try routes(app)
}
