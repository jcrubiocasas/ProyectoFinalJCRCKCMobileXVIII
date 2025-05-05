package com.gptravel.gptravel.data.local.db

import androidx.room.Database
import androidx.room.RoomDatabase
import com.gptravel.gptravel.data.local.dao.AdvancedItineraryDao
import com.gptravel.gptravel.data.local.entity.AdvancedItineraryEntity

@Database(entities = [AdvancedItineraryEntity::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun advancedItineraryDao(): AdvancedItineraryDao
}
