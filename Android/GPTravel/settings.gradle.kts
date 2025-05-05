pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }

    // ❌ No pongas `from(...)` aquí, Gradle lo carga solo si está en `gradle/libs.versions.toml`
    versionCatalogs {
        create("libs")
    }
}

rootProject.name = "GPTravel"
include(":app")
