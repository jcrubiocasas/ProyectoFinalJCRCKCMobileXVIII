package com.gptravel.gptravel

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.core.view.WindowCompat
import androidx.navigation.compose.rememberNavController
import com.gptravel.gptravel.navigation.NavGraph
import com.gptravel.gptravel.ui.theme.GPTravelTheme
import com.google.accompanist.systemuicontroller.rememberSystemUiController
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        setContent {
            GPTravelContent()
        }
    }
}

@Composable
fun GPTravelContent() {
    GPTravelTheme {
        val systemUiController = rememberSystemUiController()
        val useDarkIcons = MaterialTheme.colorScheme.background.luminance() > 0.5f
        val navController = rememberNavController()

        // Cambia el color de la status bar según el tema
        SideEffect {
            systemUiController.setSystemBarsColor(
                color = Color.Transparent,
                darkIcons = useDarkIcons
            )
        }

        Surface(
            color = MaterialTheme.colorScheme.background
        ) {
            NavGraph(navController = navController)
        }
    }
}
