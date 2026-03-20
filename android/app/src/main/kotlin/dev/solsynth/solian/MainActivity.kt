package dev.solsynth.solian

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Intent
import android.os.ParcelUuid
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.sharedpreferences.LegacySharedPreferencesPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import java.util.UUID

class MainActivity : FlutterFragmentActivity()
{
    private val CHANNEL = "dev.solsynth.solian/notifications"
    private val MEET_CHANNEL = "dev.solsynth.solian/meet_bluetooth"
    private val MEET_SERVICE_UUID: UUID = UUID.fromString("0000FFF0-0000-1000-8000-00805F9B34FB")
    private var meetAdvertiseCallback: AdvertiseCallback? = null

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdvertising" -> {
                    val meetId = call.argument<String>("meetId")
                    if (meetId.isNullOrBlank()) {
                        result.error("invalid_meet_id", "Meet id is required.", null)
                    } else {
                        startMeetAdvertising(meetId, result)
                    }
                }
                "stopAdvertising" -> {
                    stopMeetAdvertising()
                    result.success(true)
                }
                else -> result.notImplemented()
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

    override fun onDestroy() {
        stopMeetAdvertising()
        super.onDestroy()
    }

    private fun startMeetAdvertising(meetId: String, result: MethodChannel.Result) {
        val meetBytes = parseUuidToBytes(meetId)
        if (meetBytes == null) {
            result.error("invalid_meet_id", "Meet id must be a UUID.", null)
            return
        }

        val manager = getSystemService(BLUETOOTH_SERVICE) as? BluetoothManager
        val adapter = manager?.adapter
        if (adapter == null || !adapter.isEnabled) {
            result.error("bluetooth_unavailable", "Bluetooth must be turned on.", null)
            return
        }

        val advertiser = adapter.bluetoothLeAdvertiser
        if (advertiser == null) {
            result.error("bluetooth_unavailable", "BLE advertising is not available on this device.", null)
            return
        }

        stopMeetAdvertising()

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .setConnectable(false)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(MEET_SERVICE_UUID))
            .addServiceData(ParcelUuid(MEET_SERVICE_UUID), meetBytes)
            .build()

        val callback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
                meetAdvertiseCallback = this
                result.success(true)
            }

            override fun onStartFailure(errorCode: Int) {
                meetAdvertiseCallback = null
                result.error(
                    "advertise_failed",
                    "Unable to advertise nearby meet id. Error code: $errorCode",
                    errorCode,
                )
            }
        }

        advertiser.startAdvertising(settings, data, callback)
    }

    private fun stopMeetAdvertising() {
        val manager = getSystemService(BLUETOOTH_SERVICE) as? BluetoothManager
        val advertiser = manager?.adapter?.bluetoothLeAdvertiser
        val callback = meetAdvertiseCallback
        if (advertiser != null && callback != null) {
            advertiser.stopAdvertising(callback)
        }
        meetAdvertiseCallback = null
    }

    private fun parseUuidToBytes(value: String): ByteArray? {
        return try {
            val uuid = UUID.fromString(value)
            val buffer = ByteArray(16)
            val most = uuid.mostSignificantBits
            val least = uuid.leastSignificantBits
            for (i in 0 until 8) {
                buffer[i] = ((most ushr (8 * (7 - i))) and 0xFF).toByte()
                buffer[8 + i] = ((least ushr (8 * (7 - i))) and 0xFF).toByte()
            }
            buffer
        } catch (_: IllegalArgumentException) {
            null
        }
    }
}
