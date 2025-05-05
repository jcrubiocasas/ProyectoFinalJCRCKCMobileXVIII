
import Foundation
import SwiftData

@Model
class SavedItinerary {
    var id: String
    var title: String
    var itineraryDescription: String
    var duration: Int
    var latitude: Double
    var longitude: Double
    var imageAI: String
    var imageReal: String?
    var address: String?
    var phone: String?
    var website: String?
    var openingHours: String?
    var source: String?
    var category: String?

    // ✅ Required init para SwiftData
    required init(id: String,
                  title: String,
                  itineraryDescription: String,
                  duration: Int,
                  latitude: Double,
                  longitude: Double,
                  imageAI: String,
                  imageReal: String? = nil,
                  address: String? = nil,
                  phone: String? = nil,
                  website: String? = nil,
                  openingHours: String? = nil,
                  source: String? = nil,
                  category: String? = nil) {
        self.id = id
        self.title = title
        self.itineraryDescription = itineraryDescription
        self.duration = duration
        self.latitude = latitude
        self.longitude = longitude
        self.imageAI = imageAI
        self.imageReal = imageReal
        self.address = address
        self.phone = phone
        self.website = website
        self.openingHours = openingHours
        self.source = source
        self.category = category
    }

    // ✅ Convenience init desde modelo de red
    convenience init(from itinerary: AdvancedItinerary) {
        self.init(
            id: itinerary.id,
            title: itinerary.title,
            itineraryDescription: itinerary.description,
            duration: itinerary.duration,
            latitude: itinerary.latitude,
            longitude: itinerary.longitude,
            imageAI: itinerary.imageAI,
            imageReal: itinerary.imageReal,
            address: itinerary.address,
            phone: itinerary.phone,
            website: itinerary.website,
            openingHours: itinerary.opening_hours,
            source: itinerary.source,
            category: itinerary.category
        )
    }
}

