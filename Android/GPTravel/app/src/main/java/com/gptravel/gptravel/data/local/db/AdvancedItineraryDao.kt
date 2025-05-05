package com.gptravel.gptravel.data.local.db

import androidx.room.*
import com.gptravel.gptravel.data.local.entity.AdvancedItineraryEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface AdvancedItineraryDao {
    @Query("SELECT * FROM advanced_itineraries")
    fun getAllItineraries(): Flow<List<AdvancedItineraryEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertItinerary(itinerary: AdvancedItineraryEntity)

    @Query("DELETE FROM advanced_itineraries")
    suspend fun deleteAll()
}