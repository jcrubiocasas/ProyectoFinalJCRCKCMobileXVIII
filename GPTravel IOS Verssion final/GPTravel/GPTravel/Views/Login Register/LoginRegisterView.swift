import SwiftUI
import SwiftData

struct LoginRegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authService: AuthService

    @StateObject private var loginVM: LoginViewModel
    @StateObject private var registerVM: RegisterViewModel

    @State private var isLoginMode = true
    @State private var showError = false
    @State private var navigateToHome = false
    @State private var showFaceIDButton = false
    @State private var randomBackground = "Fondo 1"
    @AppStorage("isSimpleBackgroundEnabled") private var isSimpleBackgroundEnabled = false

    init() {
        let authService = AuthService.shared
        _loginVM = StateObject(wrappedValue: LoginViewModel(authService: authService))
        _registerVM = StateObject(wrappedValue: RegisterViewModel(authService: authService))
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
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

                VStack(spacing: 20) {
                    Image("GPTravel_Logo_Recolor")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width / 2,
                                  y: geometry.size.height * 0.2)
                    Text(isLoginMode ? "Iniciar sesión" : "Registrar usuario")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        
                    
                    if !isLoginMode {
                        TextField("Nombre completo", text: $registerVM.fullName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                    }
                    
                    TextField("Usuario (Email)", text: isLoginMode ? $loginVM.username : $registerVM.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    SecureField("Contraseña", text: isLoginMode ? $loginVM.password : $registerVM.password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button(action: handleAction) {
                        Text(isLoginMode ? "Iniciar sesión" : "Registrar usuario")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    if showFaceIDButton {
                        Button(action: authenticateWithFaceID) {
                            Label("Acceder con Face ID", systemImage: "faceid")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                                .padding(.horizontal)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Button(action: { isLoginMode.toggle() }) {
                        Text(isLoginMode ? "¿No tienes cuenta? Registrarse" : "¿Ya tienes cuenta? Iniciar sesión")
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                    
                    if showError {
                        Text(currentError)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    if !registerVM.successMessage.isEmpty {
                        Text(registerVM.successMessage)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .padding()
                .onReceive(registerVM.$successMessage) { success in
                    if !success.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoginMode = true
                            clearForm()
                        }
                    }
                }
                .onReceive(authService.$isAuthenticated) { authenticated in
                    if authenticated {
                        navigateToHome = true
                    }
                }
                .onAppear {
                    randomBackground = "playa\(Int.random(in: 1...6))"
                    if authService.isAuthenticated {
                        navigateToHome = true
                    } else {
                        checkFaceIDAvailable()
                    }
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                        .environmentObject(authService)
                }
            }
        }
    }

    // MARK: - Helpers

    private var currentError: String {
        isLoginMode ? loginVM.errorMessage : registerVM.errorMessage
    }

    private func handleAction() {
        showError = false

        if isLoginMode {
            loginVM.login(context: modelContext) { success in
                if !success {
                    showError = true
                }
            }
        } else {
            registerVM.register()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !registerVM.errorMessage.isEmpty {
                    showError = true
                }
            }
        }
    }

    private func clearForm() {
        registerVM.fullName = ""
        registerVM.username = ""
        registerVM.password = ""
        registerVM.errorMessage = ""
        registerVM.successMessage = ""
    }

    private func checkFaceIDAvailable() {
        if authService.autoLoginEnabled {
            if let data = KeychainHelper.shared.read(service: "gptravel", account: "authToken"),
               let savedToken = String(data: data, encoding: .utf8),
               !savedToken.isEmpty {
                showFaceIDButton = true
            }
        }
    }

    private func authenticateWithFaceID() {
        FaceIDHelper.authenticate { success in
            if success {
                triggerHapticFeedback()
                authService.restoreSessionFromKeychain()
            }
        }
    }
}


func triggerHapticFeedback() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
// MARK: - Preview
#Preview {
    if let container = try? ModelContainer(for: SavedItinerary.self) {
        LoginRegisterView()
            .environmentObject(AuthService.shared)
            .modelContainer(container)
    } else {
        Text("❌ Error cargando Preview")
    }
}
