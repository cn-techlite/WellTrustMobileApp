# Preserve metadata used by Android libraries and Flutter plugins that inspect
# annotations, generic types, or enclosing classes at runtime.
-keepattributes RuntimeVisibleAnnotations,RuntimeInvisibleAnnotations,AnnotationDefault
-keepattributes Signature,InnerClasses,EnclosingMethod

# The Android entry point and generated plugin registrant are referenced by the
# framework/manifest rather than directly by application code.
-keep class com.welltrust.well_trust_mobile_app.MainActivity { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Preserve Java/Kotlin methods called from native code by Flutter plugins.
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Preserve enum helpers commonly accessed through platform channels.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
