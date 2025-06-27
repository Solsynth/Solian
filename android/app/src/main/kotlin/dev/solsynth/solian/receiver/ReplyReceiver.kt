package dev.solsynth.solian.receiver

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.RemoteInput
import dev.solsynth.solian.network.ApiClient

class ReplyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val remoteInput = RemoteInput.getResultsFromIntent(intent)
        if (remoteInput != null) {
            val replyText = remoteInput.getCharSequence("key_text_reply").toString()
            val roomId = intent.getStringExtra("room_id")
            val messageId = intent.getStringExtra("message_id")
            val notificationId = intent.getIntExtra("notification_id", 0)

            if (roomId != null && messageId != null) {
                ApiClient(context).sendMessage(roomId, replyText, messageId) {
                    val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    notificationManager.cancel(notificationId)
                }
            }
        }
    }
}
