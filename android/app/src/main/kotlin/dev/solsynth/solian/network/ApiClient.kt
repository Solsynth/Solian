package dev.solsynth.solian.network

import android.content.Context
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

class ApiClient(private val context: Context) {
    private val client = OkHttpClient()

    fun sendMessage(roomId: String, content: String, repliedMessageId: String, callback: () -> Unit) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val token = prefs.getString("flutter.token", null)
        val serverUrl = prefs.getString("flutter.serverUrl", null)

        if (token == null || serverUrl == null) {
            return
        }

        val url = "$serverUrl/chat/$roomId/messages"

        val json = JSONObject()
        json.put("content", content)
        json.put("replied_message_id", repliedMessageId)

        val requestBody = json.toString().toRequestBody("application/json; charset=utf-8".toMediaType())

        val request = Request.Builder()
            .url(url)
            .post(requestBody)
            .addHeader("Authorization", "AtField $token")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                // Handle failure
                callback()
            }

            override fun onResponse(call: Call, response: Response) {
                // Handle success
                callback()
            }
        })
    }
}
