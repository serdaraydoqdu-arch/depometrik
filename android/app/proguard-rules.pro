# Google ML Kit Text Recognition - Proguard & R8 Keep Rules
# Ignore warnings from missing optional language models (Chinese, Japanese, Korean, Devanagari)
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.**

# Keep ML Kit classes safe from aggressive obfuscation
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
