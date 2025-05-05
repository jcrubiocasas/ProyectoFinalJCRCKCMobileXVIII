package com.gptravel.gptravel.ui.advanced

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.rememberAsyncImagePainter
import com.gptravel.gptravel.domain.model.AdvancedItinerary

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdvancedResultsSheet(
    itinerary: AdvancedItinerary,
    onSave: () -> Unit,
    onDiscard: () -> Unit,
    onDismiss: () -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp),
        modifier = Modifier.fillMaxHeight()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            Image(
                painter = rememberAsyncImagePainter(model = itinerary.imageReal ?: itinerary.imageAI),
                contentDescription = null,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentScale = ContentScale.Crop
            )
            Spacer(modifier = Modifier.height(16.dp))

            Text(text = itinerary.title, style = MaterialTheme.typography.headlineSmall)
            Spacer(modifier = Modifier.height(8.dp))

            Text(text = "Duración estimada: ${itinerary.duration} minutos")
            Spacer(modifier = Modifier.height(8.dp))

            Text(text = itinerary.description, style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.height(12.dp))

            Text(text = "Dirección: ${itinerary.address}", style = MaterialTheme.typography.bodySmall)
            Text(text = "Teléfono: ${itinerary.phone}", style = MaterialTheme.typography.bodySmall)
            Text(text = "Web: ${itinerary.website}", style = MaterialTheme.typography.bodySmall)
            Text(text = "Categoría: ${itinerary.category}", style = MaterialTheme.typography.bodySmall)
            Text(text = "Horario: ${itinerary.openingHours}", style = MaterialTheme.typography.bodySmall)
            Spacer(modifier = Modifier.height(24.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Button(onClick = onSave, modifier = Modifier.weight(1f)) {
                    Text("Guardar itinerario")
                }
                Spacer(modifier = Modifier.width(16.dp))
                OutlinedButton(onClick = onDiscard, modifier = Modifier.weight(1f)) {
                    Text("Descartar")
                }
            }
        }
    }
}
