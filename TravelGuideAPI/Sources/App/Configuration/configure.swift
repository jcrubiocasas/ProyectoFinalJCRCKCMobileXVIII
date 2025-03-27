import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    
    // Permitir conexiones externas
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
    
    // Configuración de la base de datos PostgreSQL
    var postgresConfig = PostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "travelguide"
    )
    app.databases.use(.postgres(configuration: postgresConfig), as: .psql)

    // Configuración del firmante JWT
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "default-secret"))

    // Creacion de usuarios
    app.migrations.add(CreateUser())

    // register routes
    try routes(app)
}
