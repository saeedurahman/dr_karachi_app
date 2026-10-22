import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.drkarachi"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val keyAliasVal = keystoreProperties.getProperty("keyAlias")
                val keyPassVal = keystoreProperties.getProperty("keyPassword")
                val storePassVal = keystoreProperties.getProperty("storePassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")

                if (keyAliasVal.isNullOrBlank() || keyPassVal.isNullOrBlank() ||
                    storePassVal.isNullOrBlank() || storeFilePath.isNullOrBlank()) {
                    throw GradleException(
                        "android/key.properties is missing one or more required keys: " +
                        "keyAlias, keyPassword, storePassword, storeFile."
                    )
                }

                keyAlias = keyAliasVal
                keyPassword = keyPassVal
                storePassword = storePassVal
                storeFile = file(storeFilePath)
            }
        }
    }

    defaultConfig {
        applicationId = "com.drkarachi"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                val isReleaseTask = gradle.startParameter.taskNames.any {
                    it.contains("Release", ignoreCase = true) || it.contains("assemble", ignoreCase = true)
                }
                if (isReleaseTask) {
                    throw GradleException(
                        "Release build failed: 'android/key.properties' is missing. " +
                        "Copy 'android/key.properties.example' to 'android/key.properties' and configure keystore passwords. " +
                        "Release builds will NEVER fall back to debug signing."
                    )
                }
            }

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
