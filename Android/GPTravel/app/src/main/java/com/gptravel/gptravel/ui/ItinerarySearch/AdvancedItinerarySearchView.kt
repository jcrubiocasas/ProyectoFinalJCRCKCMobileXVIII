package com.gptravel.gptravel.ui.advanced

import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.gptravel.gptravel.model.AdvancedItinerary

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdvancedItinerarySearchView(viewModel: AdvancedItineraryViewModel = viewModel()) {
    val context = LocalContext.current
    val bottomSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    var showSheet by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("Datos de búsqueda", style = MaterialTheme.typography.titleLarge)

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = viewModel.city,
            onValueChange = { viewModel.city = it },
            label = { Text("Ciudad") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = viewModel.timeAvailable,
            onValueChange = { viewModel.timeAvailable = it },
            label = { Text("Horas disponibles") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = viewModel.numResults,
            onValueChange = { viewModel.numResults = it },
            label = { Text("Número de resultados") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                viewModel.searchItinerary {
                    showSheet = true
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
        ) {
            if (viewModel.isLoading) {
                CircularProgressIndicator(modifier = Modifier.size(24.dp), color = MaterialTheme.colorScheme.onPrimary)
            } else {
                Text("Buscar itinerario Avanzado")
            }
        }
    }

    if (showSheet && viewModel.currentItinerary != null) {
        ModalBottomSheet(
            onDismissRequest = { showSheet = false },
            sheetState = bottomSheetState
        ) {
            val itinerary = viewModel.currentItinerary!!

            Column(modifier = Modifier.padding(16.dp)) {
                Text(itinerary.title, style = MaterialTheme.typography.headlineSmall)
                Spacer(modifier = Modifier.height(8.dp))
                Text(itinerary.description)
                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Button(
                        onClick = {
                            viewModel.saveItinerary(itinerary) {
                                Toast.makeText(context, "Itinerario guardado", Toast.LENGTH_SHORT).show()
                                showSheet = false
                            }
                        },
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Guardar itinerario")
                    }

                    Spacer(modifier = Modifier.width(16.dp))

                    OutlinedButton(
                        onClick = {
                            viewModel.discardItinerary()
                            showSheet = false
                        },
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Descartar")
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}
