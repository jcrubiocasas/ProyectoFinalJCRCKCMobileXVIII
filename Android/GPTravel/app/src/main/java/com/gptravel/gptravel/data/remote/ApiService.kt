package com.gptravel.gptravel.data.remote

import com.gptravel.gptravel.data.model.LoginRequestDTO
import com.gptravel.gptravel.data.model.LoginResponseDTO
import com.gptravel.gptravel.data.model.RegisterRequestDTO
import retrofit2.http.Body
import retrofit2.http.POST

interface ApiService {

    @POST("/auth/login")
    suspend fun login(@Body request: LoginRequestDTO): LoginResponseDTO

    @POST("/auth/register")
    suspend fun register(@Body request: RegisterRequestDTO)
}
