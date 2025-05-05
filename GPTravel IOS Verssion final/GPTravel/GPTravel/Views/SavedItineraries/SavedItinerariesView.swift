import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct SavedItinerariesView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AdvancedItineraryViewModel()

    @State private var selected: AdvancedItinerary?
    @State private var randomBackground = "Fondo 1"

    var body: some View {
        NavigationStack {
            ZStack {
                Image(randomBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                List {
                    ForEach(Array(viewModel.savedItineraries.enumerated()), id: \.element.id) { index, itinerary in
                        Button {
                            selected = itinerary
                        } label: {
                            SavedItineraryCardView(
                                itinerary: itinerary,
                                index: index,
                                imageURL: viewModel.imageURL(for: itinerary)
                            )
                        }
                        .listRowBackground(Color.clear) // Fondo transparente por celda
                    }
                }
                .scrollContentBackground(.hidden) // Oculta fondo del List por defecto
            }
            .onAppear {
                viewModel.loadLocalItineraries(context: context)
                randomBackground = "playa\(Int.random(in: 1...6))"
            }
            .navigationTitle("Itinerarios guardados")
            .sheet(item: $selected) { itinerary in
                AdvancedResultsSheetView(
                    itineraries: [itinerary],
                    authService: authService,
                    mode: .saved,
                    onDelete: { itinerary in
                        viewModel.deleteLocal(itinerary, context: context)
                        viewModel.deleteRemote(itinerary)
                        DispatchQueue.main.async {
                            self.selected = nil
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    SavedItinerariesView()
        .environmentObject(AuthService.shared)
        .modelContainer(for: [SavedItinerary.self])
}
