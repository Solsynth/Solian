package dev.solsynth.solian

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.sharedpreferences.LegacySharedPreferencesPlugin

class MainActivity : FlutterActivity()
{
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // https://github.com/flutter/flutter/issues/153075#issuecomment-2693189362
        flutterEngine.plugins.add(LegacySharedPreferencesPlugin())
    }
}
