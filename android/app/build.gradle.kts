plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

android {
    namespace = "com.example.quote_vault"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.quote_vault"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val localProps = Properties().apply {
            val f = rootProject.file("local.properties")
            if (f.exists()) {
                f.inputStream().use { load(it) }
            }
        }

        fun readConfig(name: String): String? {
            val fromGradle = (project.findProperty(name) as String?)?.trim()
            if (!fromGradle.isNullOrEmpty()) return fromGradle
            val fromLocal = localProps.getProperty(name)?.trim()
            if (!fromLocal.isNullOrEmpty()) return fromLocal
            val fromEnv = System.getenv(name)?.trim()
            if (!fromEnv.isNullOrEmpty()) return fromEnv
            return null
        }

        fun quoteString(value: String): String {
            val escaped = value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
            return "\"$escaped\""
        }

        val supabaseUrl = readConfig("SUPABASE_URL") ?: ""
        val supabaseAnonKey = readConfig("SUPABASE_ANON_KEY") ?: ""

        buildConfigField("String", "SUPABASE_URL", quoteString(supabaseUrl))
        buildConfigField("String", "SUPABASE_ANON_KEY", quoteString(supabaseAnonKey))
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Daily AppWidget refresh.
    implementation("androidx.work:work-runtime-ktx:2.10.0")
}
