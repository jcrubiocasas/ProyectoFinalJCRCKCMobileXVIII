package com.gptravel.gptravel.ui.advanced

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.gptravel.gptravel.data.local.db.AdvancedItineraryEntity
import com.gptravel.gptravel.data.remote.ApiService
import com.gptravel.gptravel.domain.model.AdvancedItinerary
import com.gptravel.gptravel.domain.repository.AuthRepository
import com.gptravel.gptravel.domain.repository.AdvancedItineraryRepository
import com.gptravel.gptravel.util.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AdvancedItineraryViewModel @Inject constructor(
    private val apiService: ApiService,
    private val authRepository: AuthRepository,
    private val itineraryRepository: AdvancedItineraryRepository
) : ViewModel() {

    var destination = MutableStateFlow("")
    var timeAvailable = MutableStateFlow("")
    var maxResults = MutableStateFlow(1)

    private val _loading = MutableStateFlow(false)
    val loading = _loading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage = _errorMessage.asStateFlow()

    private val _currentItinerary = MutableStateFlow<AdvancedItinerary?>(null)
    val currentItinerary: StateFlow<AdvancedItinerary?> = _currentItinerary.asStateFlow()

    fun searchItinerary() {
        _loading.value = true
        _errorMessage.value = null
        viewModelScope.launch {
            try {
                val token = authRepository.getToken()
                val response = apiService.generateAdvancedItinerary(
                    token = "Bearer $token",
                    request = mapOf(
                        "destination" to destination.value,
                        "timeAvailable" to timeAvailable.value,
                        "maxResults" to maxResults.value
                    )
                )
                _currentItinerary.value = response
            } catch (e: Exception) {
                _errorMessage.value = "Error al buscar itinerario: ${e.message}"
                Log.e("AdvancedItineraryVM", "Error", e)
            } finally {
                _loading.value = false
            }
        }
    }

    fun saveItineraryLocally() {
        currentItinerary.value?.let { itinerary ->
            viewModelScope.launch {
                itineraryRepository.insertItinerary(itinerary.toEntity())
            }
        }
    }

    fun discardItinerary() {
        _currentItinerary.value = null
    }

    fun getAllLocalItineraries(): StateFlow<List<AdvancedItineraryEntity>> {
        return itineraryRepository.getAllItineraries()
    }
}
