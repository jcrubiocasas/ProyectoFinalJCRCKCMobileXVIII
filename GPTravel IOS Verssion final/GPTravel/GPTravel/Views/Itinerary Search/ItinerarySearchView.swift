import SwiftUI

struct ItinerarySearchView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ItineraryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Datos de búsqueda")
                        .font(.title2)
                        .bold()

                    TextField("Ubicación (Ciudad)", text: $viewModel.location)
                        .textFieldStyle(.roundedBorder)

                    TextField("Detalles de interés", text: $viewModel.details)
                        .textFieldStyle(.roundedBorder)

                    TextField("Minutos disponibles", text: $viewModel.availableMinutes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Button(action: {
                        viewModel.searchItineraries()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Buscar Itinerarios")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.location.isEmpty || viewModel.availableMinutes.isEmpty)
                }
                .padding()

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Buscar Itinerario")
            .sheet(isPresented: $viewModel.showResultsSheet) {
                ResultsSheetView(
                    itineraries: $viewModel.itineraries,
                    authService: authService,
                    addItinerary: viewModel.addItinerary,
                    discardItinerary: viewModel.discardItinerary
                )
                .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    let authService = AuthService()
    authService.token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // token de ejemplo
    authService.endpoint = "http://dev.equinsaparking.com:10605"

    return ItinerarySearchView()
        .environmentObject(authService)
}
