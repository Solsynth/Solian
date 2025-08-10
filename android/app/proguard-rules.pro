# JNI Zero initialization (required for WebRTC native method registration)
-keep class livekit.org.jni_zero.JniInit {
    # Keep the init method un-obfuscated for native code callback
    private static java.lang.Object[] init();
}