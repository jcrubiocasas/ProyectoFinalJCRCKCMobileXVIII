import Foundation
import SwiftData

class SavedItineraryRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func deleteAll() {
        let fetchDescriptor = FetchDescriptor<SavedItinerary>()
        if let all = try? context.fetch(fetchDescriptor) {
            all.forEach { context.delete($0) }
        }
    }

    func saveAll(from itineraries: [AdvancedItinerary]) {
        itineraries.forEach {
            let saved = SavedItinerary(from: $0)
            context.insert(saved)
        }
    }

    func fetchAll() -> [SavedItinerary] {
        let descriptor = FetchDescriptor<SavedItinerary>()
        return (try? context.fetch(descriptor)) ?? []
    }
}
