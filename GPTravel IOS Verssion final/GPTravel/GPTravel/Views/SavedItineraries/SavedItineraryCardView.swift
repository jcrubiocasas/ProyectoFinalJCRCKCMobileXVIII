
import SwiftUI
import SDWebImageSwiftUI

struct SavedItineraryCardView: View {
    let itinerary: AdvancedItinerary
    let index: Int
    let imageURL: URL?

    var body: some View {
        HStack(spacing: 12) {
            if index % 2 == 0 {
                itineraryImage
                itineraryDescription
            } else {
                itineraryDescription
                itineraryImage
            }
        }
        .padding()
        .background(
            // Fondo translúcido para legibilidad
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .cornerRadius(16)
        .shadow(radius: 2)
        .padding(.vertical, 4)
    }

    private var itineraryImage: some View {
        WebImage(url: imageURL)
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.3))
            .scaledToFill()
            .frame(width: 80, height: 80)
            .background(
                Image("default_image")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.3)
            )
            .clipped()
            .cornerRadius(10)
    }

    private var itineraryDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(itinerary.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(itinerary.description)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.primary)
        }
    }
}

