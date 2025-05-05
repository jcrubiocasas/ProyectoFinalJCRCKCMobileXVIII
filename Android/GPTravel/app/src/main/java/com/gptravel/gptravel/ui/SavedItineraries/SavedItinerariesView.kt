package com.gptravel.gptravel.ui.SavedItineraries

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.gptravel.gptravel.ui.search.AdvancedItinerarySearchView
import com.gptravel.gptravel.ui.saved.SavedItinerariesView
import com.gptravel.gptravel.ui.map.ShowMapWithUserLocation

sealed class BottomNavItem(var title: String, var icon: ImageVector, var route: String) {
    object Search : BottomNavItem("Buscar", Icons.Default.Search, "search")
    object Saved : BottomNavItem("Guardados", Icons.Default.Place, "saved")
    object Map : BottomNavItem("Mapa", Icons.Default.Map, "map")
}

@Composable
fun MainScreen() {
    val navController = rememberNavController()
    Scaffold(
        bottomBar = { BottomNavigationBar(navController) }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = BottomNavItem.Search.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(BottomNavItem.Search.route) { AdvancedItinerarySearchView() }
            composable(BottomNavItem.Saved.route) { SavedItinerariesView() }
            composable(BottomNavItem.Map.route) { ShowMapWithUserLocation() }
        }
    }
}

@Composable
fun BottomNavigationBar(navController: NavHostController) {
    val items = listOf(
        BottomNavItem.Search,
        BottomNavItem.Saved,
        BottomNavItem.Map
    )
    NavigationBar {
        val navBackStackEntry by navController.currentBackStackEntryAsState()
        val currentRoute = navBackStackEntry?.destination?.route
        items.forEach { item ->
            NavigationBarItem(
                icon = { Icon(item.icon, contentDescription = item.title) },
                label = { Text(item.title) },
                selected = currentRoute == item.route,
                onClick = {
                    if (currentRoute != item.route) {
                        navController.navigate(item.route) {
                            popUpTo(navController.graph.startDestinationId) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                }
            )
        }
    }
}
