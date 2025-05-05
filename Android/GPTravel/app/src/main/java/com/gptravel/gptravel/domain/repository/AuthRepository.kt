package com.gptravel.gptravel.domain.repository

import com.gptravel.gptravel.data.model.LoginRequestDTO
import com.gptravel.gptravel.data.model.RegisterRequestDTO
import com.gptravel.gptravel.util.Result

interface AuthRepository {
    suspend fun login(request: LoginRequestDTO): Result<String>
    suspend fun register(request: RegisterRequestDTO): Result<Unit>
    suspend fun generateAdvancedItinerary(
        token: String,
        destination: String,
        details: String,
        maxVisitTime: Int,
        maxResults: Int
    ): List<AdvancedItinerary>

}
