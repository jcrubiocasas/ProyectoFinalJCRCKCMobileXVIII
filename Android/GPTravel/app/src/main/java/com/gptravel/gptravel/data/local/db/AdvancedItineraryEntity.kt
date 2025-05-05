package com.gptravel.gptravel.data.local.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "advanced_itineraries")
data class AdvancedItineraryEntity(
    @PrimaryKey val id: String,
    val title: String,
    val description: String,
    val duration: String,
    val imageAI: String?,
    val imageReal: String?,
    val latitude: Double,
    val longitude: Double,
    val address: String?,
    val phone: String?,
    val website: String?,
    val openingHours: String?,
    val source: String?,
    val category: String?
)