package dev.solsynth.solian.service

import android.app.PendingIntent
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.RemoteInput
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import dev.solsynth.solian.MainActivity
import dev.solsynth.solian.receiver.ReplyReceiver
import org.json.JSONObject

class MessagingService: FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        val type = remoteMessage.data["type"]
        if (type == "messages.new") {
            handleMessageNotification(remoteMessage)
        } else {
            // Handle other notification types
        }
    }

    private fun handleMessageNotification(remoteMessage: RemoteMessage) {
        val data = remoteMessage.data
        val metaString = data["meta"] ?: return
        val meta = JSONObject(metaString)

        val pfp = meta.optString("pfp", null)
        val roomId = meta.optString("room_id", null)
        val messageId = meta.optString("message_id", null)

        val notificationId = System.currentTimeMillis().toInt()

        val replyLabel = "Reply"
        val remoteInput = RemoteInput.Builder("key_text_reply")
            .setLabel(replyLabel)
            .build()

        val replyIntent = Intent(this, ReplyReceiver::class.java).apply {
            putExtra("room_id", roomId)
            putExtra("message_id", messageId)
            putExtra("notification_id", notificationId)
        }

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val replyPendingIntent = PendingIntent.getBroadcast(
            applicationContext,
            notificationId,
            replyIntent,
            pendingIntentFlags
        )

        val action = NotificationCompat.Action.Builder(
            android.R.drawable.ic_menu_send,
            replyLabel,
            replyPendingIntent
        )
            .addRemoteInput(remoteInput)
            .build()

        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.putExtra("room_id", roomId)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, pendingIntentFlags)

        val notificationBuilder = NotificationCompat.Builder(this, "messages")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(remoteMessage.notification?.title)
            .setContentText(remoteMessage.notification?.body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .addAction(action)

        if (pfp != null) {
            Glide.with(applicationContext)
                .asBitmap()
                .load(pfp)
                .into(object : CustomTarget<Bitmap>() {
                    override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                        notificationBuilder.setLargeIcon(resource)
                        NotificationManagerCompat.from(applicationContext).notify(notificationId, notificationBuilder.build())
                    }

                    override fun onLoadCleared(placeholder: Drawable?) {}
                })
        } else {
            NotificationManagerCompat.from(this).notify(notificationId, notificationBuilder.build())
        }
    }
}
