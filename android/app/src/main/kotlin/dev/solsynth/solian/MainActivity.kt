package dev.solsynth.solian

import android.bluetooth.BluetoothAdapter
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.sharedpreferences.LegacySharedPreferencesPlugin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
{
    private val CHANNEL = "dev.solsynth.solian/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // https://github.com/flutter/flutter/issues/153075#issuecomment-2693189362
        flutterEngine.plugins.add(LegacySharedPreferencesPlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initialLink") {
                val roomId = intent.getStringExtra("room_id")
                if (roomId != null) {
                    result.success("/rooms/$roomId")
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }

    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val roomId = intent.getStringExtra("room_id")
        if (roomId != null) {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("newLink", "/rooms/$roomId")
        }
    }

}
