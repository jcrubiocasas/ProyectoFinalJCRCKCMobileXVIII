package com.gptravel.gptravel.data.repository

import com.gptravel.gptravel.data.local.dao.AdvancedItineraryDao
import com.gptravel.gptravel.data.local.entity.AdvancedItineraryEntity
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class AdvancedItineraryRepository @Inject constructor(
    private val dao: AdvancedItineraryDao
) {
    fun getAllItineraries(): Flow<List<AdvancedItineraryEntity>> = dao.getAll()

    suspend fun insertItinerary(itinerary: AdvancedItineraryEntity) {
        dao.insert(itinerary)
    }

    suspend fun deleteItinerary(itinerary: AdvancedItineraryEntity) {
        dao.delete(itinerary)
    }

    suspend fun clearAll() {
        dao.clearAll()
    }
}