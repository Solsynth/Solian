package com.azhon.flutter_app_update

import android.app.Activity
import android.content.Context
import android.text.TextUtils
import androidx.annotation.NonNull
import com.azhon.appupdate.config.Constant
import com.azhon.appupdate.listener.OnButtonClickListener
import com.azhon.appupdate.listener.OnDownloadListener
import com.azhon.appupdate.manager.DownloadManager
import com.azhon.appupdate.util.ApkUtil
import com.azhon.appupdate.util.NotificationUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.io.File


class FlutterAppUpdatePlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var activity: Activity
    private var events: EventChannel.EventSink? = null
    private var manager: DownloadManager? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "azhon_app_update")
        channel.setMethodCallHandler(this)
        val eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "azhon_app_update_listener")
        eventChannel.setStreamHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null) {
            this.events = events
        }
    }

    override fun onCancel(arguments: Any?) {

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getVersionCode" -> {
                getVersionCode(result)
            }

            "getVersionName" -> {
                getVersionName(result)
            }

            "update" -> {
                update(call, result)
            }

            "cancel" -> {
                cancel(result)
            }

            "install" -> {
                install(call, result)
            }

            "release" -> {
                release(result)
            }

            "cancelNotify" -> {
                cancelNotify(result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getVersionCode(result: Result) {
        val versionCode = ApkUtil.getVersionCode(applicationContext)
        result.success(versionCode)
    }

    private fun getVersionName(result: Result) {
        val packageInfo =
            applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0)
        result.success(packageInfo.versionName)
    }

    private fun install(call: MethodCall, result: Result) {
        var authorities = call.argument<String?>("authorities")
        val path = call.argument<String>("path")
        if (TextUtils.isEmpty(authorities)) {
            authorities =
                Constant.AUTHORITIES ?: "${applicationContext.packageName}.fileProvider"
        }
        ApkUtil.installApk(applicationContext, authorities!!, File(path!!))
        result.success(true)
    }

    /**
     * 判断参数是否为空来设置
     */
    private fun update(call: MethodCall, result: Result) {
        val model = call.argument<HashMap<String, Any>>("model")
        //获取图标
        val smallIcon = applicationContext.resources.getIdentifier(
            model!!["smallIcon"] as String, "mipmap", applicationContext.packageName
        )
        manager = DownloadManager.Builder(activity).run {
            apkName(model["apkName"] as String)
            apkUrl(model["apkUrl"] as String)
            smallIcon(smallIcon)
            showNotification(model["showNotification"] as Boolean)
            jumpInstallPage(model["jumpInstallPage"] as Boolean)
            showBgdToast(model["showBgdToast"] as Boolean)
            onDownloadListener(downloadListener)
            onButtonClickListener(buttonListener)
            if (notNull(model, "apkMD5")) {
                apkMD5(model["apkMD5"] as String)
            }
            build()
        }
        manager?.download()
        result.success(true)
    }

    private fun cancel(result: Result) {
        manager?.cancel()
        result.success(true)
    }

    private fun release(result: Result) {
        manager?.release()
        result.success(true)
    }

    private fun cancelNotify(result: Result) {
        NotificationUtil.cancelNotification(applicationContext)
        result.success(true)
    }

    //判断是否为空
    private fun notNull(model: HashMap<String, Any>, key: String): Boolean {
        if (model[key] is String) {
            return !TextUtils.isEmpty(model[key].toString())
        }
        return model[key] != null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    private val downloadListener: OnDownloadListener = object : OnDownloadListener {
        override fun start() {
            events?.success(json("start").toString())
        }

        override fun downloading(max: Int, progress: Int) {
            val json = json("downloading")
            json.put("max", max)
            json.put("progress", progress)
            events?.success(json.toString())
        }

        override fun done(apk: File) {
            manager = null
            val json = json("done")
            json.put("apk", apk.path)
            events?.success(json.toString())
        }

        override fun cancel() {
            events?.success(json("cancel").toString())
        }

        override fun error(e: Throwable) {
            val json = json("error")
            json.put("exception", e.message)
            events?.success(json.toString())
        }
    }
    private val buttonListener: OnButtonClickListener = object : OnButtonClickListener {

        override fun onButtonClick(id: Int) {
            val json = json("onButtonClick")
            json.put("id", id)
            events?.success(json.toString())
        }
    }

    private fun json(type: String): JSONObject {
        val json = JSONObject()
        json.put("type", type)
        return json
    }
}
