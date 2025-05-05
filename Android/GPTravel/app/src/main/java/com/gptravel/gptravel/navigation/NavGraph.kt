package com.gptravel.gptravel.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.gptravel.gptravel.ui.login.LoginScreen
import com.gptravel.gptravel.ui.register.RegisterScreen
import com.gptravel.gptravel.ui.navigation.Routes

@Composable
fun NavGraph(navController: NavHostController) {
    NavHost(navController = navController, startDestination = Routes.LOGIN) {
        composable(route = Routes.LOGIN) {
            LoginScreen(navController = navController)
        }
        composable(route = Routes.REGISTER) {
            RegisterScreen(navController = navController)
        }
        // Puedes agregar más rutas aquí como:
        // composable(route = Routes.HOME) { HomeScreen(navController) }
    }
}

val sessionManager = remember { SessionManager(LocalContext.current) }
val isLoggedIn = sessionManager.fetchAuthToken() != null

NavHost(
navController = navController,
startDestination = if (isLoggedIn) Routes.MainScreen else Routes.Login
) {
    composable(Routes.Login) { LoginScreen(navController) }
    composable(Routes.Register) { RegisterScreen(navController) }
    composable(Routes.MainScreen) { MainScreen() }
}

