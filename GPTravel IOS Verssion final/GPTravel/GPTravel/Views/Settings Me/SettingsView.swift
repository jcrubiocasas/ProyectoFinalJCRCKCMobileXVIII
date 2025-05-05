import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var meVM = MeViewModel()
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled = false
    @AppStorage("isSimpleBackgroundEnabled") private var isSimpleBackgroundEnabled = false
    @State private var showAcknowledgements = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Perfil")) {
                    if meVM.isLoading {
                        ProgressView()
                    } else if !meVM.fullName.isEmpty {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading) {
                                Text(meVM.fullName)
                                    .font(.headline)
                                Text(meVM.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Text("Cargando datos del usuario...")
                    }
                }

                Section(header: Text("Configuraciones")) {
                    Toggle("Autologin", isOn: $authService.autoLoginEnabled)
                    Toggle("Modo oscuro", isOn: $isDarkModeEnabled)
                        .onChange(of: isDarkModeEnabled) { newValue in
                            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                        }
                    Toggle("FaceID / TouchID", isOn: $isFaceIDEnabled)
                    Toggle("Fondo sencillo (sin imágenes)", isOn: $isSimpleBackgroundEnabled)
                }
                
                

                Section(header: Text("Servidor")) {
                    TextField("Endpoint", text: $authService.endpoint)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section(header: Text("Email Emergencia")) {
                    TextField("Email de Emergencia", text: Binding(
                        get: { UserDefaults.standard.string(forKey: "emergencyEmail") ?? "" },
                        set: { UserDefaults.standard.set($0, forKey: "emergencyEmail") }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                }

                Section {
                    HStack {
                        Spacer()
                        Button("Agradecimientos") {
                            showAcknowledgements = true
                        }
                        Spacer()
                    }
                }
                
                if !meVM.errorMessage.isEmpty {
                    Section {
                        Text(meVM.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button(role: .destructive) {
                            authService.logout()
                        } label: {
                            Text("Cerrar sesión")
                        }
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Button("Eliminar cuenta", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        Spacer()
                    }
                }

                
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                meVM.setAuthService(authService)
                meVM.fetchUserDetails()
            }
            .sheet(isPresented: $showAcknowledgements) {
                AcknowledgementsView()
                    .presentationDetents([.medium])
            }
            .alert("¿Seguro que deseas eliminar tu cuenta?", isPresented: $showDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    meVM.deleteAccount()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
}
