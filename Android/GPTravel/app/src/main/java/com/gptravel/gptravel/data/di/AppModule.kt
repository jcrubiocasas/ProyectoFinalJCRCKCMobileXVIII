package com.gptravel.gptravel.data.di

package com.gptravel.gptravel.di

import android.content.Context
import androidx.room.Room
import com.gptravel.gptravel.data.local.db.AdvancedItineraryDao
import com.gptravel.gptravel.data.local.db.AppDatabase
import com.gptravel.gptravel.data.repository.AdvancedItineraryRepository
import com.gptravel.gptravel.data.remote.ApiService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDatabase(appContext: Context): AppDatabase {
        return Room.databaseBuilder(
            appContext,
            AppDatabase::class.java,
            "gptravel_db"
        ).fallbackToDestructiveMigration().build()
    }

    @Provides
    fun provideAdvancedItineraryDao(database: AppDatabase): AdvancedItineraryDao {
        return database.advancedItineraryDao()
    }

    @Provides
    @Singleton
    fun provideAdvancedItineraryRepository(
        apiService: ApiService,
        dao: AdvancedItineraryDao
    ): AdvancedItineraryRepository {
        return AdvancedItineraryRepository(apiService, dao)
    }
}
