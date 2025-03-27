import Fluent
import Vapor

func routes(_ app: Application) throws {

    try app.routes.register(collection: AuthController())
}
