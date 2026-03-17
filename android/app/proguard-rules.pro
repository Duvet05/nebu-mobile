# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# LiveKit / WebRTC
-keep class org.webrtc.** { *; }
-keep class livekit.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Google Play Core (referenced by Flutter deferred components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# OkHttp / OkIO (used by Dio's HTTP adapter on Android)
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Gson (used by various Flutter plugins for JSON)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# javax.net.ssl / security (TLS handshake classes)
-keep class javax.net.ssl.** { *; }
-keep class javax.security.cert.** { *; }
-keep class java.security.** { *; }

# FlutterSecureStorage / Android Keystore / EncryptedSharedPreferences
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Prevent R8 from stripping annotations used by JSON serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
