// Tidak perlu lagi membaca key.properties, kita hapus kodenya.

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.inews"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            // ==========================================================
            // INFORMASI KUNCI DITULIS LANGSUNG DI SINI (HARDCODED)
            // ==========================================================
            storeFile = file("C:/KunciAplikasi/inewskey.jks")
            storePassword = "123456"
            keyAlias = "inews"
            keyPassword = "123456"
        }
    }

    defaultConfig {
        applicationId = "com.example.inews"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.material:material:1.4.0")
}