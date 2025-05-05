import SwiftUI
import SDWebImageSwiftUI

struct AdvancedItineraryCardView: View {
    let itinerary: AdvancedItinerary
    let imageBaseURL: String
    let maxImageWidth: CGFloat = 360  // Fijo o adaptable si deseas

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Imagen
            if let url = imageURL(for: itinerary) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.3))
                    .scaledToFill()
                    .frame(maxWidth: maxImageWidth, maxHeight: 200)
                    .clipped()
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity) // Centrado horizontal
                    .padding(.horizontal)
            }

            // Título
            Text(itinerary.title)
                .font(.title2)
                .fontWeight(.bold)

            // Descripción
            Text(itinerary.description)
                .font(.body)
                .foregroundColor(.secondary)

            // Información adicional
            Group {
                Label("Duración estimada: \(itinerary.duration) min", systemImage: "clock")
                
                if let address = itinerary.address {
                    Label(address, systemImage: "mappin.and.ellipse")
                }

                if let phone = itinerary.phone,
                   let phoneURL = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                    Link(destination: phoneURL) {
                        Label(phone, systemImage: "phone")
                    }
                }

                if let website = itinerary.website,
                   let webURL = URL(string: website) {
                    Link(destination: webURL) {
                        Label(website, systemImage: "globe")
                    }
                }

                if let opening = itinerary.opening_hours {
                    Label("Horario: \(opening)", systemImage: "calendar")
                }

                if let source = itinerary.source {
                    Label("Fuente: \(source)", systemImage: "info.circle")
                }

                if let category = itinerary.category {
                    Label("Categoría: \(category)", systemImage: "tag")
                }
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.horizontal)
    }

    private func imageURL(for itinerary: AdvancedItinerary) -> URL? {
        let str = itinerary.imageReal ?? itinerary.imageAI
        return URL(string: str.hasPrefix("http") ? str : "\(imageBaseURL)\(str)")
    }
}

#Preview {
    AdvancedItineraryCardView(
        itinerary: AdvancedItinerary(
            id: UUID().uuidString,
            title: "Museo del Prado",
            description: "Uno de los museos de arte más importantes del mundo.",
            duration: 60,
            latitude: 40.4138,
            longitude: -3.6921,
            imageAI: "/images/itineraries/sample.png",
            imageReal: nil,
            address: "Calle Ruiz de Alarcón, 23",
            phone: "+34 913 30 28 00",
            website: "https://www.museodelprado.es",
            opening_hours: "10:00-20:00",
            source: "GPT",
            category: "Cultura"
        ),
        imageBaseURL: "https://example.com"
    )
}
/*
import SwiftUI
import SDWebImageSwiftUI

struct AdvancedItineraryCardView: View {
    let itinerary: AdvancedItinerary
    let imageBaseURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Imagen
            if let url = imageURL(for: itinerary) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.3))
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            }

            // Título
            Text(itinerary.title)
                .font(.title2)
                .fontWeight(.bold)

            // Descripción
            Text(itinerary.description)
                .font(.body)
                .foregroundColor(.secondary)

            // Información adicional
            Group {
                Label("Duración estimada: \(itinerary.duration) min", systemImage: "clock")
                
                if let address = itinerary.address {
                    Label(address, systemImage: "mappin.and.ellipse")
                }

                if let phone = itinerary.phone,
                   let phoneURL = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                    Link(destination: phoneURL) {
                        Label(phone, systemImage: "phone")
                    }
                }

                if let website = itinerary.website,
                   let webURL = URL(string: website) {
                    Link(destination: webURL) {
                        Label(website, systemImage: "globe")
                    }
                }

                if let opening = itinerary.opening_hours {
                    Label("Horario: \(opening)", systemImage: "calendar")
                }

                if let source = itinerary.source {
                    Label("Fuente: \(source)", systemImage: "info.circle")
                }

                if let category = itinerary.category {
                    Label("Categoría: \(category)", systemImage: "tag")
                }
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }

    private func imageURL(for itinerary: AdvancedItinerary) -> URL? {
        let str = itinerary.imageReal ?? itinerary.imageAI
        return URL(string: str.hasPrefix("http") ? str : "\(imageBaseURL)\(str)")
    }
}

#Preview {
    AdvancedItineraryCardView(
        itinerary: AdvancedItinerary(
            id: UUID().uuidString,
            title: "Museo del Prado",
            description: "Uno de los museos de arte más importantes del mundo.",
            duration: 60,
            latitude: 40.4138,
            longitude: -3.6921,
            imageAI: "/images/itineraries/sample.png",
            imageReal: nil,
            address: "Calle Ruiz de Alarcón, 23",
            phone: "+34 913 30 28 00",
            website: "https://www.museodelprado.es",
            opening_hours: "10:00-20:00",
            source: "GPT",
            category: "Cultura"
        ),
        imageBaseURL: "https://example.com"
    )
}
*/

