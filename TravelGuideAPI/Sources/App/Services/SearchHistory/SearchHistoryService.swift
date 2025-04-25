import Vapor
import Fluent

struct SearchHistoryService {
    // Carga los N titulos recientes de un usuario en un destino
    static func loadRecentTitles(for userID: UUID, destination: String, max: Int, db: any Database) async throws -> [String] {
        let histories = try await SearchHistory.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$destination == destination)
            .sort(\.$createdAt, .descending)
            .limit(max)
            .all()

        return histories.map { $0.title }
    }

    // Guarda una nueva entrada y elimina las más antiguas si se excede el máximo
    static func saveAndPruneHistory(for userID: UUID, destination: String, title: String, db: any Database, maxEntries: Int) async throws {
        // Guardar nueva
        let entry = SearchHistory(userID: userID, destination: destination, title: title)
        try await entry.save(on: db)

        // Contar cuántos hay
        let total = try await SearchHistory.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$destination == destination)
            .count()

        // Si hay más de los permitidos, eliminar los más antiguos
        if total > maxEntries {
            let toDeleteCount = total - maxEntries
            let toDelete = try await SearchHistory.query(on: db)
                .filter(\.$user.$id == userID)
                .filter(\.$destination == destination)
                .sort(\.$createdAt, .ascending)
                .range(0..<toDeleteCount)
                .all()

            for item in toDelete {
                try await item.delete(on: db)
            }
        }
    }
}
