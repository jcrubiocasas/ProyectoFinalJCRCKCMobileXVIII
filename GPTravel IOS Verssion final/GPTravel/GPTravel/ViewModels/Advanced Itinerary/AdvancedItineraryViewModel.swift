import Foundation
import Combine
import SwiftData
import CoreLocation

@MainActor
class AdvancedItineraryViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Public Properties
    @Published var location: String = ""
    @Published var details: String = ""
    @Published var availableMinutes: String = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var itineraries: [AdvancedItinerary] = []
    @Published var showResultsSheet = false
    @Published var savedItineraries: [AdvancedItinerary] = []
    @Published var adDTO: AdsDTO?

    // MARK: - Private Properties
    private let service: AdvancedItineraryServiceProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()

    // MARK: - Init
    init(service: AdvancedItineraryServiceProtocol = AdvancedItineraryService(), authService: AuthService = AuthService.shared) {
        self.service = service
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Itinerary search
    func searchItineraries() {
        /*
        guard !location.isEmpty, let minutes = Int(availableMinutes) else {
            errorMessage = "Introduce una ubicación válida."
            return
        }
        */
        let minutes = Int(availableMinutes) ?? 60
        
        guard !location.isEmpty else {
            errorMessage = "Introduce una ubicación válida."
            return
        }
        
        
        
        isLoading = true
        errorMessage = ""
        itineraries = []

        service.fetchAdvancedItineraries(for: location, details: details, availableMinutes: minutes, authService: authService)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] itineraries in
                self?.itineraries = itineraries
                self?.showResultsSheet = true
            }
            .store(in: &cancellables)
    }

    // MARK: - Save itinerary
    func saveItinerary(_ itinerary: AdvancedItinerary, context: ModelContext) {
        let localContext = context
        guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/save") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(itinerary)
        } catch {
            print("Error al codificar el itinerario: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.saveLocalItinerary(itinerary, context: localContext)
                self?.showResultsSheet = false
                self?.itineraries.removeAll()
                self?.loadLocalItineraries(context: localContext)
            }
        }.resume()
    }

    func discardItinerary() {
        showResultsSheet = false
        itineraries.removeAll()
    }

    // MARK: - Local persistence
    func saveLocalItinerary(_ itinerary: AdvancedItinerary, context: ModelContext) {
        let saved = SavedItinerary(from: itinerary)
        context.insert(saved)
        try? context.save()
    }

    func loadLocalItineraries(context: ModelContext) {
        let descriptor = FetchDescriptor<SavedItinerary>()
        if let results = try? context.fetch(descriptor) {
            self.savedItineraries = results.map { $0.toAdvanced() }
        }
    }

    func deleteLocal(_ itinerary: AdvancedItinerary, context: ModelContext) {
        let descriptor = FetchDescriptor<SavedItinerary>()
        if let results = try? context.fetch(descriptor),
           let match = results.first(where: { $0.id == itinerary.id }) {
            context.delete(match)
            try? context.save()
            loadLocalItineraries(context: context)
        }
    }

    func deleteRemote(_ itinerary: AdvancedItinerary) {
        guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/delete/\(itinerary.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request).resume()
    }

    func syncLocalWithBackend(context: ModelContext) {
        let localContext = context
        Task {
            let descriptor = FetchDescriptor<SavedItinerary>()
            if let all = try? localContext.fetch(descriptor) {
                all.forEach { localContext.delete($0) }
                try? localContext.save()
            }

            guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/list") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")

            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let backendItineraries = try JSONDecoder().decode([AdvancedItinerary].self, from: data)
                backendItineraries.forEach { saveLocalItinerary($0, context: localContext) }
                try? localContext.save()
                loadLocalItineraries(context: localContext)
            } catch {
                print("Error sincronizando con backend: \(error)")
            }
        }
    }

    // MARK: - Ads
    func fetchAdIfNeeded() {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        sendLocationToFetchAd(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicación: \(error)")
    }

    private func sendLocationToFetchAd(latitude: Double, longitude: Double) {
        guard let url = URL(string: "\(authService.endpoint)/ads/banner") else {
            print("❌ URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["latitude": latitude, "longitude": longitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error en la petición: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Código de respuesta: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ No se recibió data del backend")
                return
            }

            print("📦 Data recibida: \(String(data: data, encoding: .utf8) ?? "no printable")")

            do {
                let ad = try JSONDecoder().decode(AdsDTO.self, from: data)
                DispatchQueue.main.async {
                    self.adDTO = ad
                    print("✅ adDTO decodificado correctamente")
                    if let image = ad.imageReal {
                        print("🖼 URL imagen: \(image)")
                    } else {
                        print("⚠️ adDTO.imageReal está vacío")
                    }
                }
            } catch {
                print("❌ Error al decodificar adDTO: \(error)")
            }
        }.resume()
    }

    func imageURL(for itinerary: AdvancedItinerary) -> URL? {
        let str = itinerary.imageReal ?? itinerary.imageAI
        return URL(string: str.hasPrefix("http") ? str : "\(authService.endpoint)\(str)")
    }

    var adImageURL: URL? {
        guard let imagePath = adDTO?.imageReal else { return nil }
        return URL(string: imagePath.hasPrefix("http") ? imagePath : "\(authService.endpoint)\(imagePath)")
    }

    func convertAdToItinerary() -> AdvancedItinerary? {
        return adDTO?.toAdvancedItinerary()
    }

    func getLocalItineraries() -> [AdvancedItinerary] {
        return savedItineraries
    }
}





/*
import Foundation
import Alamofire
import Combine
import SwiftData
import CoreLocation

@MainActor
class AdvancedItineraryViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Public Properties
    @Published var location: String = ""
    @Published var details: String = ""
    @Published var availableMinutes: String = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var itineraries: [AdvancedItinerary] = []
    @Published var showResultsSheet = false
    @Published var savedItineraries: [AdvancedItinerary] = []
    @Published var adDTO: AdsDTO?

    // MARK: - Private Properties
    private let service: AdvancedItineraryServiceProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()

    // MARK: - Init
    init(service: AdvancedItineraryServiceProtocol = AdvancedItineraryService(), authService: AuthService = AuthService.shared) {
        self.service = service
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Itinerary search
    func searchItineraries() {
        guard !location.isEmpty, let minutes = Int(availableMinutes) else {
            errorMessage = "Introduce una ubicación y minutos válidos."
            return
        }

        isLoading = true
        errorMessage = ""
        itineraries = []

        service.fetchAdvancedItineraries(for: location, details: details, availableMinutes: minutes, authService: authService)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] itineraries in
                self?.itineraries = itineraries
                self?.showResultsSheet = true
            }
            .store(in: &cancellables)
    }

    // MARK: - Save itinerary
    func saveItinerary(_ itinerary: AdvancedItinerary, context: ModelContext) {
        let localContext = context
        guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/save") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(itinerary)
        } catch {
            print("Error al codificar el itinerario: \(error)")
            return
        }

        // Usar Alamofire para hacer la solicitud
        AF.request(request).response { [weak self] response in
            if let error = response.error {
                print("Error guardando itinerario: \(error)")
            } else {
                // Guardar en local solo cuando la solicitud sea exitosa
                DispatchQueue.main.async {
                    self?.saveLocalItinerary(itinerary, context: localContext)
                    self?.showResultsSheet = false
                    self?.itineraries.removeAll()
                    self?.loadLocalItineraries(context: localContext)
                }
            }
        }
    }
    
    // MARK: - Local persistence
    func saveLocalItinerary(_ itinerary: AdvancedItinerary, context: ModelContext) {
        print("✅ saveLocalItinerary called")

        let saved = SavedItinerary(from: itinerary)
        context.insert(saved)

        // Intentar guardar en Core Data y manejar posibles errores
        do {
            try context.save()
            print("✅ Itinerario guardado localmente: \(itinerary.title)")
        } catch {
            print("❌ Error al guardar el itinerario localmente: \(error)")
        }
    }

    func discardItinerary() {
        showResultsSheet = false
        itineraries.removeAll()
    }

    // LOAD
    func syncLocalWithBackend(context: ModelContext) {
            Task { // Hacemos la llamada asincrónica con Task
                print("✅ Sincronización con backend")
                
                let localContext = context
                let descriptor = FetchDescriptor<SavedItinerary>()
                
                // Limpiar los itinerarios locales antes de la sincronización
                if let all = try? await localContext.fetch(descriptor) {
                    all.forEach { localContext.delete($0) }
                    try? await localContext.save()
                }
                
                print("✅ Itinerarios locales borrados")

                guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/list") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")

                // Usar Alamofire para obtener itinerarios desde el backend
                AF.request(request).response { [weak self] response in
                    if let error = response.error {
                        print("❌ Error sincronizando con backend: \(error)")
                        return
                    }

                    guard let data = response.data else {
                        print("❌ No se recibió data del backend")
                        return
                    }

                    do {
                        // Decodificar los itinerarios
                        let backendItineraries = try JSONDecoder().decode([AdvancedItinerary].self, from: data)
                        print("✅ Total itinerarios descargados del backend: \(backendItineraries.count)")
                        
                        // Guardar los itinerarios en el contexto
                        backendItineraries.forEach { itinerary in
                            print("✅ Recibido: \(itinerary.title)")
                            Task {
                                await self?.saveLocalItinerary(itinerary, context: localContext)
                            }
                        }
                        try? localContext.save()

                        // Cargar los itinerarios locales
                        Task {
                            await self?.loadLocalItineraries(context: localContext)
                        }
                    } catch {
                        print("❌ Error al decodificar los itinerarios: \(error)")
                    }
                }
            }
        }

    func loadLocalItineraries(context: ModelContext) {
        let descriptor = FetchDescriptor<SavedItinerary>()
        
        do {
            let results = try context.fetch(descriptor)
            self.savedItineraries = results.map { $0.toAdvanced() }
            print("✅ Itinerarios locales cargados correctamente: \(self.savedItineraries.count)")
        } catch {
            print("❌ Error al cargar itinerarios guardados: \(error)")
        }
    }

    // DELETE
    func deleteLocal(_ itinerary: AdvancedItinerary, context: ModelContext) async {
        let descriptor = FetchDescriptor<SavedItinerary>()
        if let results = try? context.fetch(descriptor),
           let match = results.first(where: { $0.id == itinerary.id }) {
            context.delete(match)
            try? context.save()
            await loadLocalItineraries(context: context)
        }
    }

    func deleteRemote(_ itinerary: AdvancedItinerary) {
        guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/delete/\(itinerary.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        
        // Usar Alamofire para la eliminación remota
        AF.request(request).response { response in
            if let error = response.error {
                print("Error eliminando itinerario: \(error)")
            }
        }
    }

    // MARK: - Ads
    func fetchAdIfNeeded() {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        sendLocationToFetchAd(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicación: \(error)")
    }

    private func sendLocationToFetchAd(latitude: Double, longitude: Double) {
        guard let url = URL(string: "\(authService.endpoint)/ads/banner") else {
            print("❌ URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["latitude": latitude, "longitude": longitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Usar Alamofire para la solicitud de anuncios
        AF.request(request).response { [weak self] response in
            if let error = response.error {
                print("❌ Error en la solicitud de anuncio: \(error)")
                return
            }
            guard let data = response.data else {
                print("❌ No se recibió data del backend")
                return
            }
            do {
                let ad = try JSONDecoder().decode(AdsDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.adDTO = ad
                }
            } catch {
                print("❌ Error al decodificar adDTO: \(error)")
            }
        }
    }

    func imageURL(for itinerary: AdvancedItinerary) -> URL? {
        let str = itinerary.imageReal ?? itinerary.imageAI
        return URL(string: str.hasPrefix("http") ? str : "\(authService.endpoint)\(str)")
    }

    var adImageURL: URL? {
        guard let imagePath = adDTO?.imageReal else { return nil }
        return URL(string: imagePath.hasPrefix("http") ? imagePath : "\(authService.endpoint)\(imagePath)")
    }

    func convertAdToItinerary() -> AdvancedItinerary? {
        return adDTO?.toAdvancedItinerary()
    }

    func getLocalItineraries() -> [AdvancedItinerary] {
        return savedItineraries
    }
}
*/


/*
import Foundation
import Alamofire
import Combine
import SwiftData
import CoreLocation

@MainActor
class AdvancedItineraryViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Public Properties
    @Published var location: String = ""
    @Published var details: String = ""
    @Published var availableMinutes: String = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var itineraries: [AdvancedItinerary] = []
    @Published var showResultsSheet = false
    @Published var savedItineraries: [AdvancedItinerary] = []
    @Published var adDTO: AdsDTO?

    // MARK: - Private Properties
    private let service: AdvancedItineraryServiceProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()

    // MARK: - Init
    init(service: AdvancedItineraryServiceProtocol = AdvancedItineraryService(), authService: AuthService = AuthService.shared) {
        self.service = service
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Itinerary search
    func searchItineraries() {
        guard !location.isEmpty, let minutes = Int(availableMinutes) else {
            errorMessage = "Introduce una ubicación y minutos válidos."
            return
        }

        isLoading = true
        errorMessage = ""
        itineraries = []

        service.fetchAdvancedItineraries(for: location, details: details, availableMinutes: minutes, authService: authService)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] itineraries in
                self?.itineraries = itineraries
                self?.showResultsSheet = true
            }
            .store(in: &cancellables)
    }

    // MARK: - Save itinerary
    func saveItinerary(_ itinerary: AdvancedItinerary, context: ModelContext) {
        let localContext = context
        guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/save") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(itinerary)
        } catch {
            print("Error al codificar el itinerario: \(error)")
            return
        }

        // Usar Alamofire para hacer la solicitud
        AF.request(request).response { [weak self] response in
            if let error = response.error {
                print("Error guardando itinerario: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.saveLocalItinerary(itinerary, context: localContext)
                    self?.showResultsSheet = false
                    self?.itineraries.removeAll()
                    self?.loadLocalItineraries(context: localContext)
                }
            }
        }
    }
    
    // MARK: - Local persistence
    func saveLocalItinerary(_ itinerary: AdvancedItinerary, context: ModelContext) {
        print("✅ saveLocalItinerary called")

        let saved = SavedItinerary(from: itinerary)
        
        // Insertar el itinerario en el contexto
        context.insert(saved)
        
        // Intentar guardar en Core Data y manejar posibles errores
        do {
            try context.save()
            print("✅ Itinerario guardado localmente: \(itinerary.title)")
        } catch {
            print("❌ Error al guardar el itinerario localmente: \(error)")
        }
    }
     
    
    
    func discardItinerary() {
        showResultsSheet = false
        itineraries.removeAll()
    }

    
    /*
    func loadLocalItineraries(context: ModelContext) {
        // Usar `async` para hacer el fetch en el hilo principal
        Task {
            let descriptor = FetchDescriptor<SavedItinerary>()
            if let results = try? await context.fetch(descriptor) {
                self.savedItineraries = results.map { $0.toAdvanced() }
                print("Itinerarios locales cargados correctamente")
            } else {
                print("Error cargando itinerarios locales")
            }
        }
    }
    */
    
    
    // LOAD
    func syncLocalWithBackend(context: ModelContext) {
        Task {
            print("✅ Sincronizacion con backend")
            
            let localContext = context
            let descriptor = FetchDescriptor<SavedItinerary>()
            if let all = try? await localContext.fetch(descriptor) {
                all.forEach { localContext.delete($0) }
                try? await localContext.save()
            }
            print("✅ Itinerarios locales borrados")

            guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/list") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")

            // Usar Alamofire para obtener itinerarios del backend
            AF.request(request).response { [weak self] response in
                if let error = response.error {
                    print("Error sincronizando con backend: \(error)")
                    return
                }

                guard let data = response.data else {
                    print("❌ No se recibió data del backend")
                    return
                }

                do {
                    let backendItineraries = try JSONDecoder().decode([AdvancedItinerary].self, from: data)
                    backendItineraries.forEach {
                        print("✅ Recibido: \($0.title)")
                        self?.saveLocalItinerary($0, context: localContext)
                    }
                    print("✅ Total itinerarios descargados del backend: \(backendItineraries.count)")
                    try? localContext.save()
                    self?.loadLocalItineraries(context: localContext)
                } catch {
                    print("❌ Error al decodificar los itinerarios: \(error)")
                }
            }
        }
    }
    
    
    func loadLocalItineraries(context: ModelContext) {
        let descriptor = FetchDescriptor<SavedItinerary>()
        if let results = try? context.fetch(descriptor) {
            self.savedItineraries = results.map { $0.toAdvanced() }
            print("✅ Itinerarios cargados localmente: \(savedItineraries.count)")
        } else {
            print("❌ Error al cargar itinerarios guardados")
        }
    }
    
    // DELETE
    func deleteLocal(_ itinerary: AdvancedItinerary, context: ModelContext) {
        let descriptor = FetchDescriptor<SavedItinerary>()
        if let results = try? context.fetch(descriptor),
           let match = results.first(where: { $0.id == itinerary.id }) {
            context.delete(match)
            try? context.save()
            loadLocalItineraries(context: context)
        }
    }

    func deleteRemote(_ itinerary: AdvancedItinerary) {
        guard let url = URL(string: "\(authService.endpoint)/advanced-itineraries/delete/\(itinerary.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        
        // Usar Alamofire para la eliminación remota
        AF.request(request).response { response in
            if let error = response.error {
                print("Error eliminando itinerario: \(error)")
            }
        }
    }

    

    // MARK: - Ads
    func fetchAdIfNeeded() {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        sendLocationToFetchAd(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicación: \(error)")
    }

    private func sendLocationToFetchAd(latitude: Double, longitude: Double) {
        guard let url = URL(string: "\(authService.endpoint)/ads/banner") else {
            print("❌ URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authService.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["latitude": latitude, "longitude": longitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // Usar Alamofire para la solicitud de anuncios
        AF.request(request).response { [weak self] response in
            if let error = response.error {
                print("❌ Error en la solicitud de anuncio: \(error)")
                return
            }
            //if let httpResponse = response.response {
            //    print("✅ Código de respuesta: \(httpResponse.statusCode)")
            //}
            guard let data = response.data else {
                print("❌ No se recibió data del backend")
                return
            }
            //print("📦 Data recibida: \(String(data: data, encoding: .utf8) ?? "no printable")")
            do {
                let ad = try JSONDecoder().decode(AdsDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.adDTO = ad
                    //print("✅ adsDTO decodificado correctamente")
                    //if let image = ad.imageReal {
                    //    print("🖼 URL imagen: \(image)")
                    //} else {
                    //    print("⚠️ adsDTO.imageReal está vacío")
                    //}
                }
            } catch {
                print("❌ Error al decodificar adDTO: \(error)")
            }
        }
    }

    func imageURL(for itinerary: AdvancedItinerary) -> URL? {
        let str = itinerary.imageReal ?? itinerary.imageAI
        return URL(string: str.hasPrefix("http") ? str : "\(authService.endpoint)\(str)")
    }

    var adImageURL: URL? {
        guard let imagePath = adDTO?.imageReal else { return nil }
        return URL(string: imagePath.hasPrefix("http") ? imagePath : "\(authService.endpoint)\(imagePath)")
    }

    func convertAdToItinerary() -> AdvancedItinerary? {
        return adDTO?.toAdvancedItinerary()
    }

    func getLocalItineraries() -> [AdvancedItinerary] {
        return savedItineraries
    }
}
*/
