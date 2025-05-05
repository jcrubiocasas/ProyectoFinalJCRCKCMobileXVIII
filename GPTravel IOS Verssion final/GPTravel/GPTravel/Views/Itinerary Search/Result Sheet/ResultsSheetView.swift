//
//  ResultsSheetView.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 14/4/25.
//

import SwiftUI
import Alamofire
import AlamofireImage

struct ResultsSheetView: View {
    @Binding var itineraries: [Itinerary]
    var authService: AuthService
    var addItinerary: (Itinerary) -> Void
    var discardItinerary: (Itinerary) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(itineraries, id: \.id) { itinerary in
                        VStack(alignment: .leading, spacing: 8) {
                            RemoteImage(url: "\(authService.endpoint)\(itinerary.image)")

                            Text(itinerary.title)
                                .font(.headline)

                            Text(itinerary.description)
                                .font(.subheadline)

                            Text("Duración: \(itinerary.duration) minutos")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                Button("Añadir") {
                                    addItinerary(itinerary)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Descartar") {
                                    discardItinerary(itinerary)
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Resultados")
        }
    }
}

// MARK: - Carga de imagen usando Alamofire + Reintentos

struct RemoteImage: View {
    let url: String
    @State private var uiImage: UIImage? = UIImage(named: "DefaultImage") // 👈 Imagen por defecto
    @State private var retryCount = 0
    private let maxRetries = 15
    private let retryDelay: TimeInterval = 2.0

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .frame(height: 200)
                    .transition(.opacity)
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(height: 200)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let imageUrl = URL(string: url) else {
            print("URL inválida para imagen: \(url)")
            return
        }

        AF.request(imageUrl)
            .validate()
            .responseImage { response in
                switch response.result {
                case .success(let image):
                    withAnimation {
                        self.uiImage = image
                    }
                case .failure:
                    if retryCount < maxRetries {
                        retryCount += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                            loadImage() // 🔥 Reintento automático
                        }
                    } else {
                        print("❌ No se pudo cargar la imagen tras varios intentos")
                    }
                }
            }
    }
}
