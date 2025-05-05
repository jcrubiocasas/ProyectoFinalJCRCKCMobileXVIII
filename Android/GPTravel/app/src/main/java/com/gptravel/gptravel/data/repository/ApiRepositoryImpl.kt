package com.gptravel.gptravel.data.repository

import com.gptravel.gptravel.data.model.LoginRequestDTO
import com.gptravel.gptravel.data.model.RegisterRequestDTO
import com.gptravel.gptravel.data.remote.ApiService
import com.gptravel.gptravel.domain.repository.AuthRepository
import com.gptravel.gptravel.util.Result
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.HttpException
import java.io.IOException
import javax.inject.Inject

class ApiRepositoryImpl @Inject constructor(
    private val api: ApiService
) : AuthRepository {

    override suspend fun login(request: LoginRequestDTO): Result<String> {
        return withContext(Dispatchers.IO) {
            try {
                val response = api.login(request)
                Result.Success<String>(response.token)
            } catch (e: HttpException) {
                Result.Error("Error HTTP al hacer login")
            } catch (e: IOException) {
                Result.Error("No se pudo conectar al servidor. Revisa tu conexión.")
            }
        }
    }

    override suspend fun register(request: RegisterRequestDTO): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                api.register(request)
                Result.Success(Unit)
            } catch (e: HttpException) {
                Result.Error("Error HTTP al hacer registro")
            } catch (e: IOException) {
                Result.Error("No se pudo conectar al servidor. Revisa tu conexión.")
            }
        }
    }
}
