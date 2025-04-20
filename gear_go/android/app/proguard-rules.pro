# Keep Razorpay classes and interfaces
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }

# Keep Google Pay/Paisa classes and interfaces
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-keep interface com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Explicitly keep ProGuard annotations
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn proguard.annotation.**

# Keep classes and members annotated with Keep/KeepClassMembers
-keep @proguard.annotation.Keep class * { *; }
-keep @proguard.annotation.KeepClassMembers class * { *; }
-keepclassmembers class * {
    @proguard.annotation.Keep *;
    @proguard.annotation.KeepClassMembers *;
}

# Prevent obfuscation of Razorpay methods
-keepclassmembers class com.razorpay.** {
    public *;
    protected *;
}

# Preserve native methods and enums
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Ignore warnings and ensure ProGuard rules are applied
-dontwarn proguard.**
-ignorewarnings
-dontoptimize