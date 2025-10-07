# Flutter framework rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.firebase.** { *; }

# Firebase SDK rules
-keepnames class com.google.android.gms.measurement.AppMeasurement
-keep class com.google.firebase.auth.FirebaseAuth { *; }

# Google Play services rules
-keep class com.google.android.gms.common.api.internal.TaskApiCall { *; }
-keep class com.google.android.gms.common.api.internal.zaar { *; }
-keep class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    java.lang.String CREATOR;
}

# Used by firebase-database
-keepnames class com.fasterxml.jackson.databind.PropertyName
-keepclassmembers class com.fasterxml.jackson.databind.PropertyName {
    java.lang.String value();
}

# Required by cloud_firestore
-keep class com.google.protobuf.** { *; }

# For http_client - if you are using it.
-dontwarn org.apache.http.**
-keep class org.apache.http.** { *; }

# For audioplayers
-keep class androidx.core.app.NotificationCompat$Builder { *; }

# For youtube_player_flutter
-keep class com.pierfrancescosoffritti.androidyoutubeplayer.core.player.views.YouTubePlayerView { *; }
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}