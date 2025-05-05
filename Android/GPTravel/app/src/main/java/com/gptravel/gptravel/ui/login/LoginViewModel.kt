package com.gptravel.gptravel.ui.login

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavHostController
import com.gptravel.gptravel.data.local.SessionManager
import com.gptravel.gptravel.data.model.LoginRequestDTO
import com.gptravel.gptravel.data.model.LoginResponseDTO
import com.gptravel.gptravel.domain.repository.AuthRepository
import com.gptravel.gptravel.ui.navigation.Routes
import com.gptravel.gptravel.util.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class LoginViewModel @Inject constructor(
    application: Application,
    private val repository: AuthRepository
) : AndroidViewModel(application) {

    private val sessionManager = SessionManager(application.applicationContext)

    private val _tokenResponse = MutableStateFlow<LoginResponseDTO?>(null)
    val tokenResponse: StateFlow<LoginResponseDTO?> = _tokenResponse

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage

    fun login(email: String, password: String, navController: NavHostController) {
        viewModelScope.launch {
            when (val result = repository.login(LoginRequestDTO(email, password))) {
                is Result.Success -> {
                    sessionManager.saveAuthToken(result.data)
                    _tokenResponse.value = LoginResponseDTO(result.data)
                    navController.navigate(Routes.MainScreen) {
                        popUpTo(Routes.Login) { inclusive = true }
                    }
                }
                is Result.Error -> _errorMessage.value = result.message
            }
        }
    }
}
