/*
 * Copyright (c) 2016-2019 The CallKeep Authors (see the AUTHORS file)
 * SPDX-License-Identifier: ISC, MIT
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

package io.wazo.callkeep;

import static io.wazo.callkeep.CallKeepConstants.ACTION_CHECK_REACHABILITY;
import static io.wazo.callkeep.CallKeepConstants.ACTION_FAILED_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_ONGOING_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_WAKEUP_CALL;
import static io.wazo.callkeep.CallKeepConstants.BROADCAST_RECEIVER_META_DATA_KEY;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALLER_NAME;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALL_ATTRIB;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALL_NUMBER;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALL_UUID;
import static io.wazo.callkeep.CallKeepConstants.FOREGROUND_SERVICE_TYPE_MICROPHONE;
import static io.wazo.callkeep.CallKeepConstants.HOLD_SUPPORT_DATA_KEY;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.telecom.Connection;
import android.telecom.ConnectionRequest;
import android.telecom.ConnectionService;
import android.telecom.DisconnectCause;
import android.telecom.PhoneAccount;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

import io.wazo.callkeep.utils.ConstraintsMap;

// @see https://github.com/kbagchiGWC/voice-quickstart-android/blob/9a2aff7fbe0d0a5ae9457b48e9ad408740dfb968/exampleConnectionService/src/main/java/com/twilio/voice/examples/connectionservice/VoiceConnectionService.java
public class VoiceConnectionService extends ConnectionService {
    private static Boolean isAvailable;
    private static Boolean isInitialized;
    private static Boolean isReachable;
    private static PhoneAccountHandle phoneAccountHandle = null;
    private static final String TAG = "RNCK:VoiceConnectionService";
    private static final Map<String, VoiceConnection> currentConnections = new HashMap<>();
    public static Boolean hasOutgoingCall = false;
    public static VoiceConnectionService currentConnectionService = null;

    public static VoiceConnection getConnection(String connectionId) {
        if (currentConnections.containsKey(connectionId)) {
            return currentConnections.get(connectionId);
        }
        return null;
    }

    public static ConstraintsMap getSettings(@Nullable Context context) {
        return CallKeepModule.getSettings(context);
    }

    public static ConstraintsMap getForegroundSettings(@Nullable Context context) {
        ConstraintsMap settings = VoiceConnectionService.getSettings(context);
        if (settings == null) {
            return null;
        }
        return settings.getMap("foregroundService");
    }

    public static List<String> getActiveConnections() {
        return new ArrayList<>(currentConnections.keySet());
    }

    public static void endAllCalls() {
        Map<String, VoiceConnection> connectionMap = new HashMap<>(currentConnections);
        for (Map.Entry<String, VoiceConnection> connectionEntry : connectionMap.entrySet()) {
            Connection connectionToEnd = connectionEntry.getValue();
            connectionToEnd.onDisconnect();
        }
    }

    public VoiceConnectionService() {
        super();
        Log.e(TAG, "Constructor");
        isReachable = false;
        isInitialized = false;
        isAvailable = false;
        currentConnectionService = this;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        checkReachability();
    }

    public static void setPhoneAccountHandle(PhoneAccountHandle phoneAccountHandle) {
        VoiceConnectionService.phoneAccountHandle = phoneAccountHandle;
    }

    public static void setAvailable(Boolean value) {
        Log.d(TAG, "setAvailable: " + (value ? "true" : "false"));
        if (value) {
            isInitialized = true;
        }

        isAvailable = value;
    }


    public static void setReachable(Boolean value) {
        Log.d(TAG, "setReachable");
        isReachable = value;
    }

    public static void deinitConnection(String connectionId) {
        Log.d(TAG, "deinitConnection:" + connectionId);
        VoiceConnectionService.hasOutgoingCall = false;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            currentConnectionService.stopForegroundService();
        }

        currentConnections.remove(connectionId);
    }

    private ConstraintsMap getMetadataSettings() {
        try {
            Bundle metaData = getMetaData();
            if (metaData != null) {
                return new ConstraintsMap(bundleToMap(metaData));
            }
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(TAG, null, e);
        }
        return new ConstraintsMap();
    }

    @Override
    public void onCreateIncomingConnectionFailed(PhoneAccountHandle connectionManagerPhoneAccount, ConnectionRequest request) {
        super.onCreateIncomingConnectionFailed(connectionManagerPhoneAccount, request);
        Bundle extras = request.getExtras();
        assert extras != null;
        extras = extras.getBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS);
        onConnectionFailed(request, Objects.requireNonNull(extras));
    }

    @Override
    public void onCreateOutgoingConnectionFailed(PhoneAccountHandle connectionManagerPhoneAccount, ConnectionRequest request) {
        super.onCreateOutgoingConnectionFailed(connectionManagerPhoneAccount, request);
        onConnectionFailed(request, request.getExtras());
    }

    private void onConnectionFailed(ConnectionRequest request, Bundle extras) {
        String extrasUuid = extras.getString(EXTRA_CALL_UUID);
        String extrasNumber = extras.getString(EXTRA_CALL_NUMBER);
        String displayName = extras.getString(EXTRA_CALLER_NAME);
        Log.d(TAG, "onConnectionFailed: " + extrasUuid + ", number: " + extrasNumber + ", displayName:" + displayName);
        HashMap<String, Object> connectionData = this.bundleToMap(extras);
        sendCallRequestToActivity(ACTION_FAILED_CALL, connectionData);
        Log.d(TAG, "onConnectionFailed: calling");
    }

    @Override
    public Connection onCreateIncomingConnection(PhoneAccountHandle phoneAccount, ConnectionRequest request) {
        return makeIncomingCall(request);
    }

    private Connection makeIncomingCall(ConnectionRequest request) {
        Bundle extras = request.getExtras();
        assert extras != null;
        extras = extras.getBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS);
        Connection connection = makeOngoingCall(request, Objects.requireNonNull(extras));
        connection.setRinging();
        return connection;
    }

    @Override
    public Connection onCreateOutgoingConnection(PhoneAccountHandle phoneAccount, ConnectionRequest request) {
        VoiceConnectionService.hasOutgoingCall = true;

        if (!isInitialized && !isReachable) {
            this.checkReachability(request);
        }

        return makeOutgoingCall(request);
    }

    private Connection makeOutgoingCall(ConnectionRequest request) {
        fixMissingNumber(request.getAddress(), request.getExtras());
        fixMissingCallId(request.getExtras());
        if (!wakeAndCheckAvailability(request.getExtras(), false)) {
            return Connection.createFailedConnection(new DisconnectCause(DisconnectCause.LOCAL));
        } else {
            VoiceConnection connection = makeOngoingCall(request, request.getExtras());
            connection.setDialing();
            connection.initCall();
            return connection;
        }
    }

    private VoiceConnection makeOngoingCall(ConnectionRequest request, Bundle extras) {
        String extrasUuid = extras.getString(EXTRA_CALL_UUID);
        String extrasNumber = extras.getString(EXTRA_CALL_NUMBER);
        String displayName = extras.getString(EXTRA_CALLER_NAME);
        Log.d(TAG, "makeOngoingCall: " + extrasUuid + ", number: " + extrasNumber + ", displayName:" + displayName);
        // TODO: Hold all other calls
        HashMap<String, Object> connectionData = this.bundleToMap(extras);
        VoiceConnection connection = new VoiceConnection(this, connectionData);
        initConnection(extrasUuid, connection, extras, request.getAccountHandle());
        startForegroundService();
        sendCallRequestToActivity(ACTION_ONGOING_CALL, connectionData);
        Log.d(TAG, "makeOngoingCall: calling");
        return connection;
    }

    private void fixMissingNumber(Uri address, Bundle callExtras) {
        String number = address.getSchemeSpecificPart();
        String extrasNumber = callExtras.getString(EXTRA_CALL_NUMBER);
        if (extrasNumber == null || !extrasNumber.equals(number)) {
            callExtras.putString(EXTRA_CALL_NUMBER, number);
        }
    }

    private void fixMissingCallId(Bundle callExtras) {
        String extrasUUID = callExtras.getString(EXTRA_CALL_UUID);
        if (extrasUUID == null) {
            callExtras.putString(EXTRA_CALL_UUID, UUID.randomUUID().toString());
        }
    }

    private boolean wakeAndCheckAvailability(Bundle callExtras, Boolean forceWakeUp) {
        boolean isRunning = VoiceConnectionService.isRunning(this.getApplicationContext());
        // Wakeup application if needed
        if (!isRunning || forceWakeUp) {
            Log.d(TAG, "makeOngoingCall: Waking up application");
            this.wakeUpApplication(callExtras);
        }
        if (this.canMakeOutgoingCall() && isReachable) {
            return true;
        }
        Log.d(TAG, "makeOngoingCall: not available");
        return false;
    }

    private void startForegroundService() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            // Foreground services not required before SDK 28
            return;
        }
        Log.d(TAG, "[VoiceConnectionService] startForegroundService");
        ConstraintsMap foregroundSettings = getForegroundSettings(getApplicationContext());
        if (foregroundSettings == null) {
            Log.w(TAG, "[VoiceConnectionService] Not creating foregroundService because not configured");
            return;
        }
        String NOTIFICATION_CHANNEL_ID = foregroundSettings.getString("channelId");
        String channelName = foregroundSettings.getString("channelName");
        NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE);
        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        assert manager != null;
        manager.createNotificationChannel(chan);

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID);
        notificationBuilder.setOngoing(true)
                .setContentTitle(foregroundSettings.getString("notificationTitle"))
                .setPriority(NotificationManager.IMPORTANCE_MIN)
                .setCategory(Notification.CATEGORY_SERVICE);

        if (foregroundSettings.hasKey("notificationIcon")) {
            Context context = this.getApplicationContext();
            Resources res = context.getResources();
            String smallIcon = foregroundSettings.getString("notificationIcon");
            String mipmap = "mipmap/";
            String drawable = "drawable/";
            if (smallIcon.contains(mipmap)) {
                notificationBuilder.setSmallIcon(
                        res.getIdentifier(smallIcon.replace(mipmap, ""),
                                "mipmap", context.getPackageName()));
            } else if (smallIcon.contains(drawable)) {
                notificationBuilder.setSmallIcon(
                        res.getIdentifier(smallIcon.replace(drawable, ""),
                                "drawable", context.getPackageName()));
            }
        }

        Log.d(TAG, "[VoiceConnectionService] Starting foreground service");

        Notification notification = notificationBuilder.build();
        int notificationId = FOREGROUND_SERVICE_TYPE_MICROPHONE;
        if (!foregroundSettings.isNull("notificationId")) {
            notificationId = foregroundSettings.getInt("notificationId");
        }
        startForeground(notificationId, notification);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    private void stopForegroundService() {
        Log.d(TAG, "[VoiceConnectionService] stopForegroundService");
        ConstraintsMap foregroundSettings = getForegroundSettings(getApplicationContext());
        if (foregroundSettings == null) {
            Log.d(TAG, "[VoiceConnectionService] Discarding stop foreground service, no service configured");
            return;
        }
        stopForeground(Service.STOP_FOREGROUND_REMOVE);
    }

    private void wakeUpApplication(Bundle extras) {
        Intent headlessIntent = new Intent(
                this.getApplicationContext(),
                CallKeepBackgroundMessagingService.class
        );
        headlessIntent.putExtras(new Bundle(extras));
        Log.d(TAG, "wakeUpApplication: " +
                extras.get(EXTRA_CALL_UUID) +
                ", number : " + extras.get(EXTRA_CALL_NUMBER) +
                ", displayName:" + extras.get(EXTRA_CALLER_NAME));
        ComponentName name = this.getApplicationContext().startService(headlessIntent);
        if (name != null) {
            CallKeepBackgroundMessagingService.acquireWakeLockNow(this.getApplicationContext());
        }
        broadcastAction(ACTION_WAKEUP_CALL, bundleToMap(extras));
    }

    private void checkReachability(ConnectionRequest request) {
        Log.d(TAG, "checkReachability");
        checkReachability();
        new Handler().postDelayed(
                () -> {
                    Log.d(TAG, "checkReachability timeout, force wakeup");
                    wakeUpApplication(request.getExtras());
                },
                2000);
    }

    private void checkReachability() {
        sendCallRequestToActivity(ACTION_CHECK_REACHABILITY, null);
        broadcastAction(ACTION_CHECK_REACHABILITY, null);
    }

    private Boolean canMakeOutgoingCall() {
        return isAvailable;
    }

    private void initConnection(String uuid, VoiceConnection connection, Bundle extras, PhoneAccountHandle accountHandle) {
        connection.setInitializing();
        connection.setExtras(extras);

        int capabilities = connection.getConnectionCapabilities() | Connection.CAPABILITY_MUTE;
        ConstraintsMap settings = getSettings(getApplicationContext());
        if (settings != null) {
            if (!settings.isNull("supportsHolding") && settings.getBoolean("supportsHolding")) {
                capabilities |= Connection.CAPABILITY_SUPPORT_HOLD;
            }
        } else {
            ConstraintsMap metDataSettings = getMetadataSettings();
            if (Boolean.TRUE.equals(metDataSettings.getBoolean(HOLD_SUPPORT_DATA_KEY))) {
                capabilities |= Connection.CAPABILITY_SUPPORT_HOLD;
            }
        }
        connection.setConnectionCapabilities(capabilities);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Context context = getApplicationContext();
            TelecomManager telecomManager = (TelecomManager) context.getSystemService(Context.TELECOM_SERVICE);
            PhoneAccount phoneAccount = telecomManager.getPhoneAccount(accountHandle);

            //If the phone account is self managed, then this connection must also be self managed.
            if ((phoneAccount.getCapabilities() & PhoneAccount.CAPABILITY_SELF_MANAGED) == PhoneAccount.CAPABILITY_SELF_MANAGED) {
                Log.d(TAG, "[VoiceConnectionService] PhoneAccount is SELF_MANAGED, so connection will be too");
                connection.setConnectionProperties(Connection.PROPERTY_SELF_MANAGED);
            } else {
                Log.d(TAG, "[VoiceConnectionService] PhoneAccount is not SELF_MANAGED, so connection won't be either");
            }
        }

        // Get other connections for conferencing
        List<Connection> conferenceConnections = new ArrayList<>(currentConnections.values());
        connection.setConferenceableConnections(conferenceConnections);

        currentConnections.put(uuid, connection);

        // ‍️Weirdly on some Samsung phones (A50, S9...) using `setInitialized` will not display the native UI ...
        // when making a call from the native Phone application. The call will still be displayed correctly without it.
        if (!Build.MANUFACTURER.equalsIgnoreCase("Samsung")) {
            connection.setInitialized();
        }
    }

    @Override
    public void onConference(Connection connection1, Connection connection2) {
        super.onConference(connection1, connection2);
        VoiceConnection voiceConnection1 = (VoiceConnection) connection1;
        VoiceConnection voiceConnection2 = (VoiceConnection) connection2;

        VoiceConference voiceConference = new VoiceConference(phoneAccountHandle);
        voiceConference.addConnection(voiceConnection1);
        voiceConference.addConnection(voiceConnection2);

        connection1.onUnhold();
        connection2.onUnhold();

        this.addConference(voiceConference);
    }

    /*
     * Send call request to the RNCallKeepModule
     */
    private void broadcastAction(final String action, @Nullable final HashMap<?, ?> attributeMap) {
        try {
            Bundle appMetaData = getMetaData();
            if (appMetaData == null) return;
            String receiverName = appMetaData.getString(BROADCAST_RECEIVER_META_DATA_KEY);
            if (receiverName == null) return;
            Class<?> clazz = Class.forName(receiverName);
            Intent intent = new Intent(getApplicationContext(), clazz);
            intent.setAction(getPackageName() + "." + action);
            if (attributeMap != null) {
                intent.putExtra(EXTRA_CALL_ATTRIB, attributeMap);
            }
            sendBroadcast(intent);
        } catch (ClassNotFoundException | PackageManager.NameNotFoundException e) {
            Log.e(TAG, null, e);
        }
    }

    private void sendCallRequestToActivity(final String action, @Nullable final HashMap attributeMap) {
        new Handler().post(() -> {
            Intent intent = new Intent(action);
            if (attributeMap != null) {
                intent.putExtra(EXTRA_CALL_ATTRIB, attributeMap);
            }
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        });
    }

    @Nullable
    protected Bundle getMetaData() throws PackageManager.NameNotFoundException {
        ServiceInfo serviceInfo = getPackageManager().getServiceInfo(new ComponentName(this, getClass()), PackageManager.GET_META_DATA);
        return serviceInfo.metaData;
    }

    private HashMap<String, Object> bundleToMap(Bundle extras) {
        HashMap<String, Object> extrasMap = new HashMap<>();
        Set<String> keySet = extras.keySet();

        for (String key : keySet) {
            if (extras.get(key) != null) {
                Object value = extras.get(key);
                if (value != null) {
                    extrasMap.put(key, value);
                }
            }
        }
        return extrasMap;
    }

    /**
     * https://stackoverflow.com/questions/5446565/android-how-do-i-check-if-activity-is-running
     *
     * @param context Context
     * @return boolean
     */
    public static boolean isRunning(Context context) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<RunningTaskInfo> tasks = activityManager.getRunningTasks(Integer.MAX_VALUE);

        for (RunningTaskInfo task : tasks) {
            if (context.getPackageName().equalsIgnoreCase(task.baseActivity.getPackageName()))
                return true;
        }

        return false;
    }
}
