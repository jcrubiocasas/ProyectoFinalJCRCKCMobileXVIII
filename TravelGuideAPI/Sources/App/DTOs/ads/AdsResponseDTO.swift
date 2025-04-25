import Vapor

struct AdsResponseDTO: Content {
    var id: String? = nil
    var title: String = ""
    var description: String = ""
    var duration: Int = 0
    var imageAI: String
    var imageReal: String = ""
    var address: String = ""
    var phone: String = ""
    var website: String = ""
    var opening_hours: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var category: String = ""
    var source: String = ""
}
