package com.gptravel.gptravel.ui.register

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.gptravel.gptravel.data.model.RegisterRequestDTO
import com.gptravel.gptravel.domain.repository.AuthRepository
import com.gptravel.gptravel.util.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class RegisterViewModel @Inject constructor(
    private val repository: AuthRepository
) : ViewModel() {

    private val _registerSuccess = MutableStateFlow<Boolean?>(null)
    val registerSuccess: StateFlow<Boolean?> = _registerSuccess

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage

    fun register(fullName: String, email: String, password: String) {
        viewModelScope.launch {
            when (val result = repository.register(RegisterRequestDTO(fullName, email, password))) {
                is Result.Success -> _registerSuccess.value = true
                is Result.Error -> {
                    _registerSuccess.value = false
                    _errorMessage.value = result.message
                }
            }
        }
    }
}
