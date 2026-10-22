# Flutter ProGuard / R8 Rules

# Flutter core embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_secure_storage
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# cached_network_image
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**
