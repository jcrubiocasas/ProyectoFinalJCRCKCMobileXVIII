package com.gptravel.gptravel.ui.main

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.gptravel.gptravel.ui.map.FullMapView
import com.gptravel.gptravel.ui.saved.SavedItinerariesView
import com.gptravel.gptravel.ui.search.AdvancedItinerarySearchView

@Composable
fun MainScreen() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            BottomNavigationBar(navController = navController)
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = "search",
            modifier = Modifier.padding(innerPadding)
        ) {
            composable("search") { AdvancedItinerarySearchView() }
            composable("saved") { SavedItinerariesView() }
            composable("map") { FullMapView() }
        }
    }
}
