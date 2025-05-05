import Foundation

extension SavedItinerary {
    func toAdvanced() -> AdvancedItinerary {
        AdvancedItinerary(
            id: self.id,
            title: self.title,
            description: self.itineraryDescription,
            duration: self.duration,
            latitude: self.latitude,
            longitude: self.longitude,
            imageAI: self.imageAI ?? "/images/itineraries/default.png",
            imageReal: self.imageReal,
            address: self.address,
            phone: self.phone,
            website: self.website,
            opening_hours: self.openingHours,
            source: self.source,
            category: self.category
        )
    }
}
