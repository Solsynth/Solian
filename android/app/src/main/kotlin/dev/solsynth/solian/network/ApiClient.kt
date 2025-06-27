package dev.solsynth.solian.network

import android.content.Context
import android.content.SharedPreferences
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import org.json.JSONObject
import java.io.IOException

class ApiClient(private val context: Context) {
    private val client = OkHttpClient()
    private val sharedPreferences: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    fun sendMessage(roomId: String, message: String, replyTo: String, callback: (Boolean) -> Unit) {
        val token = sharedPreferences.getString("flutter.token", null)
        if (token == null) {
            callback(false)
            return
        }

        val json = JSONObject().apply {
            put("content", message)
            put("reply_to", replyTo)
        }
        val body = json.toString().toRequestBody("application/json; charset=utf-8".toMediaType())
        val request = Request.Builder()
            .url("https://solian.dev/api/rooms/$roomId/messages")
            .header("Authorization", "Bearer $token")
            .post(body)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                callback(false)
            }

            override fun onResponse(call: Call, response: Response) {
                callback(response.isSuccessful)
            }
        })
    }
}