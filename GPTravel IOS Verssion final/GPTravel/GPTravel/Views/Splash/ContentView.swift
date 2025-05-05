import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        if authService.isAuthenticated {
            HomeView()
        } else {
            LoginRegisterView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
