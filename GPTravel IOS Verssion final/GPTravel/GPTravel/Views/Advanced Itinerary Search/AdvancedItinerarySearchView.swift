import SwiftUI
import SwiftData
import CoreLocation
import SDWebImageSwiftUI

struct AdvancedItinerarySearchView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AdvancedItineraryViewModel()
    @FocusState private var focusedField: Field?
    @State private var randomBackground = "Fondo 1"
    @State private var selectedAd: AdvancedItinerary?
    @AppStorage("isSimpleBackgroundEnabled") private var isSimpleBackgroundEnabled = false

    private enum Field {
        case location, details, minutes
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if isSimpleBackgroundEnabled {
                    Color.white
                        .ignoresSafeArea()
                } else {
                    Image(randomBackground)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        //.edgesIgnoringSafeArea(.all)
                }

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }

                VStack(spacing: 16) {
                    Text("Datos de búsqueda")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    locationField
                    detailsField
                    minutesField
                    searchButton

                    if let adImage = viewModel.adImageURL {
                        Text("Publicidad")
                            .foregroundColor(.white)

                        WebImage(url: adImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                            .onTapGesture {
                                selectedAd = viewModel.convertAdToItinerary()
                            }
                    }

                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $viewModel.showResultsSheet) {
                AdvancedResultsSheetView(
                    itineraries: viewModel.itineraries,
                    authService: authService,
                    mode: .search,
                    onSave: { itinerary in
                        viewModel.saveItinerary(itinerary, context: context)
                    },
                    onDiscard: viewModel.discardItinerary
                )
            }
            .sheet(item: $selectedAd) { itinerary in
                AdvancedResultsSheetView(
                    itineraries: [itinerary],
                    authService: authService,
                    mode: .saved
                )
            }
        }
        .onAppear {
            randomBackground = "playa\(Int.random(in: 1...6))"
            viewModel.fetchAdIfNeeded()
        }
    }

    private var locationField: some View {
        TextField("Ubicación", text: $viewModel.location)
            .focused($focusedField, equals: .location)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 32)
    }

    private var detailsField: some View {
        TextField("Detalles (opcional)", text: $viewModel.details)
            .focused($focusedField, equals: .details)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 32)
    }

    private var minutesField: some View {
        TextField("Minutos disponibles", text: $viewModel.availableMinutes)
            .focused($focusedField, equals: .minutes)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 32)
    }

    private var searchButton: some View {
        Button(action: {
            focusedField = nil
            viewModel.searchItineraries()
        }) {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text("Buscar itinerario Avanzado")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .accentColor(.blue)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading)
        .padding(.horizontal, 32)
    }
}


#Preview {
    AdvancedItinerarySearchView()
        .environmentObject(AuthService.shared)
        .modelContainer(for: SavedItinerary.self)
}
