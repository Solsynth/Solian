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

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.drawable.Icon;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.telecom.Connection;
import android.telecom.PhoneAccount;
import android.telecom.PhoneAccountHandle;
import android.telecom.TelecomManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.WindowManager;

import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import io.wazo.callkeep.utils.Callback;
import io.wazo.callkeep.utils.ConstraintsMap;
import io.wazo.callkeep.utils.ConstraintsArray;
import io.wazo.callkeep.utils.MapUtils;
import io.wazo.callkeep.utils.PermissionUtils;

import static io.wazo.callkeep.CallKeepConstants.*;

import org.json.JSONException;
import org.json.JSONObject;

// @see https://github.com/kbagchiGWC/voice-quickstart-android/blob/9a2aff7fbe0d0a5ae9457b48e9ad408740dfb968/exampleConnectionService/src/main/java/com/twilio/voice/examples/connectionservice/VoiceConnectionServiceActivity.java
public class CallKeepModule {
    private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
    private static final String E_CONNECTION_SERVICE_NOT_AVAILABLE = "E_CONNECTION_SERVICE_NOT_AVAILABLE";
    private static final String TAG = "FLT:CallKeepModule";

    private static TelecomManager telecomManager;
    private static TelephonyManager telephonyManager;
    private static PhoneAccountHandle accountHandle;
    private static ConstraintsMap settings;
    private static boolean hasSetup = false;
    private final Context context;
    private boolean isReceiverRegistered = false;
    private VoiceBroadcastReceiver voiceBroadcastReceiver;
    private final List<String> requiredPermissions = new LinkedList<>();
    private Activity currentActivity = null;
    private final MethodChannel eventChannel;

    public CallKeepModule(Context context, BinaryMessenger messenger) {
        this.context = context;
        this.eventChannel = new MethodChannel(messenger, "FlutterCallKeep.Event");
    }

    public static PhoneAccountHandle getAccountHandle() {
        return accountHandle;
    }

    public void setActivity(Activity activity) {
        this.currentActivity = activity;
    }

    public void dispose() {
        if (voiceBroadcastReceiver == null || this.context == null) return;
        LocalBroadcastManager.getInstance(this.context).unregisterReceiver(voiceBroadcastReceiver);
        VoiceConnectionService.setPhoneAccountHandle(null);
        isReceiverRegistered = false;
    }

    public boolean handleMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "setup": {
                setup(new ConstraintsMap(call.argument("options")));
                result.success(null);
            }
            break;
            case "displayIncomingCall": {
                displayIncomingCallImpl(
                        call.argument("uuid"),
                        call.argument("handle"),
                        call.argument("callerName"),
                        call.argument("additionalData")
                );
                result.success(null);
            }
            break;
            case "answerIncomingCall": {
                answerIncomingCall(call.argument("uuid"));
                result.success(null);
            }
            break;
            case "startCall": {
                startCall(
                        call.argument("uuid"),
                        call.argument("handle"),
                        call.argument("callerName"),
                        call.argument("additionalData")
                );
                result.success(null);
            }
            break;
            case "endCall": {
                endCall(call.argument("uuid"));
                result.success(null);
            }
            break;
            case "endAllCalls": {
                endAllCalls();
                result.success(null);
            }
            break;
            case "requestPermissions": {
                requestPermissions(new ConstraintsArray(call.argument("additionalPermissions")), result);
            }
            break;
            case "checkDefaultPhoneAccount": {
                checkDefaultPhoneAccount(result);
            }
            break;
            case "setOnHold": {
                setOnHold(call.argument("uuid"), call.argument("hold"));
                result.success(null);
            }
            break;
            case "reportEndCallWithUUID": {
                reportEndCallWithUUID(call.argument("uuid"), call.argument("reason"), call.argument("notify"));
                result.success(null);
            }
            break;
            case "reportStartedCallWithUUID": {
                reportStartedCallWithUUID(call.argument("uuid"));
                result.success(null);
            }
            break;
            case "rejectCall": {
                rejectCall(call.argument("uuid"));
                result.success(null);
            }
            break;
            case "setMutedCall": {
                setMutedCall(call.argument("uuid"), call.argument("muted"));
                result.success(null);
            }
            break;
            case "setCallAudio": {
                setCallAudio(call.argument("uuid"), call.argument("audioRoute"));
                result.success(null);
            }
            break;
            case "sendDTMF": {
                sendDTMF(call.argument("uuid"), call.argument("key"));
                result.success(null);
            }
            break;
            case "updateDisplay": {
                updateDisplay(call.argument("uuid"), call.argument("callerName"), call.argument("handle"));
                result.success(null);
            }
            break;
            case "hasPhoneAccount": {
                hasPhoneAccount(result);
            }
            break;
            case "hasOutgoingCall": {
                hasOutgoingCall(result);
            }
            break;
            case "hasPermissions": {
                hasPermissions(result);
            }
            break;
            case "setAvailable": {
                setAvailable(call.argument("available"));
                result.success(null);
            }
            break;
            case "setReachable": {
                setReachable(call.argument("reachable"));
                result.success(null);
            }
            break;
            case "setCurrentCallActive": {
                setCurrentCallActive(call.argument("uuid"));
                result.success(null);
            }
            break;
            case "openPhoneAccounts": {
                openPhoneAccounts(result);
            }
            break;
            case "backToForeground": {
                backToForeground(result);
            }
            break;
            case "foregroundService": {
                updateSettings(new ConstraintsMap(call.argument("settings")));
                result.success(null);
            }
            break;
            case "isCallActive": {
                isCallActive(call.argument("uuid"), result);
            }
            break;
            case "activeCalls": {
                activeCalls(result);
            }
            break;
            default:
                return false;
        }

        return true;
    }

    private void setup(ConstraintsMap options) {
        if (isReceiverRegistered) {
            return;
        }
        updateSettings(options);
        if (setupImpl(context, options)) {
            registerEvents();
        }
        setupRequiredPermissions(options);
    }

    private static boolean setupImpl(Context context, ConstraintsMap options) {
        boolean isServiceAvailable = isConnectionServiceAvailable();
        if (hasSetup) return isServiceAvailable;
        VoiceConnectionService.setAvailable(false);
        if (isServiceAvailable) {
            registerPhoneAccount(context, options);
            VoiceConnectionService.setPhoneAccountHandle(accountHandle);
            VoiceConnectionService.setAvailable(true);
        }
        hasSetup = true;
        return isServiceAvailable;
    }

    public static ConstraintsMap getSettings(@Nullable Context context) {
        if (settings == null) {
            fetchStoredSettings(context);
        }
        return settings;
    }

    private void updateSettings(ConstraintsMap options) {
        if (settings == null) {
            settings = options;
        } else {
            settings.merge(options.toMap());
        }
        storeSettings(settings);
    }

    private void setupRequiredPermissions(ConstraintsMap options) {
        requiredPermissions.add(Manifest.permission.READ_PHONE_STATE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            requiredPermissions.add(Manifest.permission.READ_PHONE_NUMBERS);
        }
        if (isSelfManaged(options)) {
            requiredPermissions.add(Manifest.permission.MANAGE_OWN_CALLS);
        } else {
            requiredPermissions.add(Manifest.permission.CALL_PHONE);
        }
    }

    private void registerEvents() {
        if (!isConnectionServiceAvailable()) {
            return;
        }
        voiceBroadcastReceiver = new VoiceBroadcastReceiver();
        registerReceiver();
    }

    public static void displayIncomingCall(Context context,
                                           String uuid,
                                           String handle,
                                           String callerName,
                                           Map<String, String> additionalData) {
        if (setupImpl(context, getSettings(context))) {
            displayIncomingCallImpl(uuid, handle, callerName, additionalData);
        }
    }

    private static void displayIncomingCallImpl(String uuid,
                                               String handle,
                                               String callerName,
                                               Map<String, String> additionalData) {
        Log.d(TAG, "Called displayIncomingCall");
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        Log.d(TAG, "displayIncomingCall number: " + handle + ", callerName: " + callerName);

        Bundle extras = new Bundle();
        Uri uri = Uri.fromParts(getHandleSchema(), handle, null);

        Bundle callExtras = createCallBundle(uuid, handle, callerName, additionalData);

        extras.putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, uri);
        extras.putBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS, callExtras);

        telecomManager.addNewIncomingCall(accountHandle, extras);
        Log.d(TAG, "Finished displayIncomingCall");
    }


    private void answerIncomingCall(String uuid) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        Connection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }

        conn.onAnswer();
    }


    @SuppressLint("MissingPermission")
    private void startCall(String uuid,
                           String handle,
                           String callerName,
                           Map<String, String> additionalData) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount() || !hasPermissions() || handle == null) {
            return;
        }

        Log.d(TAG, "startCall number: " + handle + ", callerName: " + callerName);

        Bundle extras = new Bundle();

        Uri uri = Uri.fromParts(getHandleSchema(), handle, null);

        Bundle callExtras = createCallBundle(uuid, handle, callerName, additionalData);

        extras.putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, accountHandle);
        extras.putBundle(TelecomManager.EXTRA_OUTGOING_CALL_EXTRAS, callExtras);
        telecomManager.placeCall(uri, extras);
    }

    private static String getHandleSchema()  {
        if (settings == null || settings.isNull("handleSchema")) {
            return PhoneAccount.SCHEME_TEL;
        } else {
            return Objects.requireNonNull(settings).getString("handleSchema");
        }
    }

    private static Bundle createCallBundle(String uuid, String handle, String callerName, Map<String, String> additionalData) {
        Bundle extras = new Bundle();
        extras.putString(EXTRA_CALL_UUID, uuid);
        extras.putString(EXTRA_CALLER_NAME, callerName);
        extras.putString(EXTRA_CALL_NUMBER, handle);
        if (additionalData != null) {
            extras.putSerializable(EXTRA_CALL_DATA, new HashMap<>(additionalData));
        }
        return extras;
    }

    private void endCall(String uuid) {
        Log.d(TAG, "endCall called");
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        Connection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        conn.onDisconnect();

        Log.d(TAG, "endCall executed");
    }


    private void endAllCalls() {
        Log.d(TAG, "endAllCalls called");
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        VoiceConnectionService.endAllCalls();

        Log.d(TAG, "endAllCalls executed");
    }


    private void requestPermissions(ConstraintsArray additionalPermissions, @NonNull MethodChannel.Result result) {
        if (!isConnectionServiceAvailable()) {
            result.error(E_CONNECTION_SERVICE_NOT_AVAILABLE, "ConnectionService not available for this version of Android.", null);
            return;
        }

        if (currentActivity == null) {
            result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null);
            return;
        }

        if (!this.hasPermissions()) {
            List<String> allPermissions = new LinkedList<>(requiredPermissions);
            for (int i = 0; i < additionalPermissions.size(); i++) {
                allPermissions.add(additionalPermissions.getString(i));
            }
            requestPermissions(
                    currentActivity,
                    allPermissions.toArray(new String[0]),
                    grantedPermissions -> result.success(grantedPermissions.size() == allPermissions.size()),
                    failedPermissions -> result.success(false)
            );
        } else {
            result.success(true);
        }
    }

    @SuppressLint("MissingPermission")
    private void checkDefaultPhoneAccount(@NonNull MethodChannel.Result result) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            result.success(true);
            return;
        }

        if (!Build.MANUFACTURER.equalsIgnoreCase("Samsung")) {
            result.success(true);
            return;
        }

        boolean hasSim = telephonyManager.getSimState() != TelephonyManager.SIM_STATE_ABSENT;

        boolean hasDefaultAccount = telecomManager.getDefaultOutgoingPhoneAccount(getHandleSchema()) != null;

        result.success(!hasSim || !hasDefaultAccount);
    }


    private void setOnHold(String uuid, Boolean shouldHold) {
        Connection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }

        if (Boolean.TRUE.equals(shouldHold)) {
            conn.onHold();
        } else {
            conn.onUnhold();
        }
    }


    private void reportEndCallWithUUID(String uuid, Integer reason, Boolean notify) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        VoiceConnection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        conn.reportDisconnect(reason, Boolean.TRUE.equals(notify));
    }

    private void reportStartedCallWithUUID(String uuid) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        VoiceConnection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        conn.onStarted();
    }


    private void rejectCall(String uuid) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            return;
        }

        Connection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }

        conn.onReject();
    }


    private void setMutedCall(String uuid, Boolean shouldMute) {
        VoiceConnection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        //if the requester wants to mute, do that. otherwise unmute
        conn.setMuted(Boolean.TRUE.equals(shouldMute));
    }


    private void setCallAudio(String uuid, Integer audioRoute) {
        VoiceConnection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        //if the requester wants to mute, do that. otherwise unmute
        conn.setAudio(audioRoute);
    }


    private void sendDTMF(String uuid, String key) {
        Connection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        char dtmf = key.charAt(0);
        conn.onPlayDtmfTone(dtmf);
    }

    private void updateDisplay(String uuid, String callerName, String handle) {
        VoiceConnection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        conn.updateDisplay(callerName, handle);
    }


    private void hasPhoneAccount(@NonNull MethodChannel.Result result) {
        ensureTelecomManagerInitialize(getAppContext());
        result.success(hasPhoneAccount());
    }


    private void hasOutgoingCall(@NonNull MethodChannel.Result result) {
        result.success(VoiceConnectionService.hasOutgoingCall);
    }


    private void hasPermissions(@NonNull MethodChannel.Result result) {
        result.success(this.hasPermissions());
    }

    private void isCallActive(String uuid, @NonNull MethodChannel.Result result) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            result.success(false);
            return;
        }

        Connection conn = VoiceConnectionService.getConnection(uuid);
        result.success(conn != null);
    }

    private void activeCalls(@NonNull MethodChannel.Result result) {
        if (!isConnectionServiceAvailable() || !hasPhoneAccount()) {
            result.success(new ArrayList<>());
            return;
        }

        result.success(VoiceConnectionService.getActiveConnections());
    }


    private void setAvailable(Boolean active) {
        VoiceConnectionService.setAvailable(active);
    }


    private void setReachable(Boolean active) {
        VoiceConnectionService.setReachable(active);
    }


    private void setCurrentCallActive(String uuid) {
        VoiceConnection conn = VoiceConnectionService.getConnection(uuid);
        if (conn == null) {
            return;
        }
        conn.setCurrent();
    }

    private void openPhoneAccounts(@NonNull MethodChannel.Result result) {
        if (!isConnectionServiceAvailable()) {
            result.error("ConnectionServiceNotAvailable", null, null);
            return;
        }

        if (Build.MANUFACTURER.equalsIgnoreCase("Samsung")) {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
            intent.setComponent(new ComponentName("com.android.server.telecom",
                    "com.android.server.telecom.settings.EnableAccountPreferenceActivity"));
            this.currentActivity.startActivity(intent);
            result.success(null);
            return;
        }

        Intent intent = new Intent(TelecomManager.ACTION_CHANGE_PHONE_ACCOUNTS);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
        this.currentActivity.startActivity(intent);
        result.success(null);
    }

    @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.M)
    private static Boolean isConnectionServiceAvailable() {
        // PhoneAccount is available since api level 23
        return Build.VERSION.SDK_INT >= 23;
    }


    @SuppressLint("WrongConstant")
    private void backToForeground(@NonNull MethodChannel.Result result) {
        Context context = getAppContext();
        String packageName = context.getPackageName();
        Intent focusIntent = Objects.requireNonNull(context.getPackageManager().getLaunchIntentForPackage(packageName)).cloneFilter();
        Activity activity = this.currentActivity;
        boolean isOpened = activity != null;
        Log.d(TAG, "backToForeground, app isOpened ?" + (isOpened ? "true" : "false"));
        if (isOpened) {
            focusIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            activity.startActivity(focusIntent);
        } else {
            focusIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK +
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED +
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD +
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
            context.startActivity(focusIntent);
        }
        result.success(isOpened);
    }

    private static void registerPhoneAccount(Context appContext, ConstraintsMap options) {
        ensureTelecomManagerInitialize(appContext);
        String appName = getApplicationName(appContext);
        PhoneAccount.Builder builder = new PhoneAccount.Builder(accountHandle, appName);
        int capabilities = 0;
        if (isSelfManaged(options)) {
            capabilities |= PhoneAccount.CAPABILITY_SELF_MANAGED;
        } else {
            capabilities |= PhoneAccount.CAPABILITY_CALL_PROVIDER;
        }

        builder.setCapabilities(capabilities);

        if (!options.isNull("imageName")) {
            int identifier = appContext.getResources().getIdentifier(settings.getString("imageName"), "drawable", appContext.getPackageName());
            Icon icon = Icon.createWithResource(appContext, identifier);
            builder.setIcon(icon);
        }

        PhoneAccount account = builder.build();
        telecomManager.registerPhoneAccount(account);
        Log.d(TAG, "Registered phone account " + account);
    }

    private static void ensureTelecomManagerInitialize(Context context) {
        if (telecomManager == null) {
            ComponentName cName = new ComponentName(context, VoiceConnectionService.class);
            String appName = getApplicationName(context);
            accountHandle = new PhoneAccountHandle(cName, appName);
            telecomManager = (TelecomManager) context.getSystemService(Context.TELECOM_SERVICE);
            telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
        }
    }

    @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.O)
    private static boolean isSelfManaged(ConstraintsMap options) {
        return !options.isNull("isSelfManaged") &&
                options.getBoolean("isSelfManaged") &&
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O;
    }

    private void sendEventToFlutter(String eventName, @NonNull ConstraintsMap params) {
        eventChannel.invokeMethod(eventName, params.toMap());
    }

    private static String getApplicationName(Context appContext) {
        ApplicationInfo applicationInfo = appContext.getApplicationInfo();
        int stringId = applicationInfo.labelRes;

        return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : appContext.getString(stringId);
    }

    private Boolean hasPermissions() {
        boolean hasPermissions = true;
        for (String permission : requiredPermissions) {
            int permissionCheck = ContextCompat.checkSelfPermission(currentActivity, permission);
            if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
                hasPermissions = false;
            }
        }

        return hasPermissions;
    }

    private static boolean hasPhoneAccount() {
        if (telecomManager == null) return false;
        PhoneAccount phoneAccount = telecomManager.getPhoneAccount(accountHandle);
        if (phoneAccount == null) return false;
        return phoneAccount.isEnabled();
    }

    private void registerReceiver() {
        if (!isReceiverRegistered) {
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(ACTION_END_CALL);
            intentFilter.addAction(ACTION_ANSWER_CALL);
            intentFilter.addAction(ACTION_INCOMING_CALL);
            intentFilter.addAction(ACTION_ONGOING_CALL);
            intentFilter.addAction(ACTION_FAILED_CALL);
            intentFilter.addAction(ACTION_REJECT_CALL);
            intentFilter.addAction(ACTION_MUTE_CALL);
            intentFilter.addAction(ACTION_UNMUTE_CALL);
            intentFilter.addAction(ACTION_DTMF_TONE);
            intentFilter.addAction(ACTION_UNHOLD_CALL);
            intentFilter.addAction(ACTION_HOLD_CALL);
            intentFilter.addAction(ACTION_AUDIO_SESSION);
            intentFilter.addAction(ACTION_CHECK_REACHABILITY);
            LocalBroadcastManager.getInstance(this.context).registerReceiver(voiceBroadcastReceiver, intentFilter);
            isReceiverRegistered = true;
        }
    }

    private Context getAppContext() {
        return this.context.getApplicationContext();
    }


    private void requestPermissions(
            Activity activity,
            final String[] permissions,
            final Callback<List<String>> successCallback,
            final Callback<List<String>> failureCallback) {
        PermissionUtils.Callback callback = (permissions_, grantResults) -> {
            List<String> grantedPermissions = new ArrayList<>();
            List<String> deniedPermissions = new ArrayList<>();

            for (int i = 0; i < permissions_.length; ++i) {
                String permission = permissions_[i];
                int grantResult = grantResults[i];

                if (grantResult == PackageManager.PERMISSION_GRANTED) {
                    grantedPermissions.add(permission);
                } else {
                    deniedPermissions.add(permission);
                }
            }

            // Success means that all requested permissions were granted.
            for (String p : permissions) {
                if (!grantedPermissions.contains(p)) {
                    // According to step 6 of the getUserMedia() algorithm
                    // "if the result is denied, jump to the step Permission
                    // Failure."
                    failureCallback.invoke(deniedPermissions);
                    return;
                }
            }
            successCallback.invoke(grantedPermissions);
        };

        PermissionUtils.requestPermissions(activity, permissions, callback);
    }

    // Store all callkeep settings in JSON
    private void storeSettings(ConstraintsMap options) {
        Context context = getAppContext();
        if (context == null) {
            Log.w(TAG, "[CallKeepModule][storeSettings] no context found.");
            return;
        }
        SharedPreferences sharedPref = context.getSharedPreferences("settings-callkeep", Context.MODE_PRIVATE);
        try {
            JSONObject jsonObject = MapUtils.convertMapToJson(options);
            String jsonString = jsonObject.toString();
            sharedPref.edit().putString("settings", jsonString).apply();
        } catch (JSONException e) {
            Log.w(TAG, "[CallKeepModule][storeSettings] exception: " + e);
        }
    }

    private static void fetchStoredSettings(Context context) {
        if (context == null) {
            Log.w(TAG, "[CallKeepModule][fetchStoredSettings] no context found.");
            return;
        }
        settings = new ConstraintsMap();

        SharedPreferences sharedPref = context.getSharedPreferences("settings-callkeep", Context.MODE_PRIVATE);
        try {
            String jsonString = sharedPref.getString("settings", (new JSONObject()).toString());
            if (jsonString != null) {
                JSONObject jsonObject = new JSONObject(jsonString);
                settings = MapUtils.convertJsonToMap(jsonObject);
            }
        } catch(JSONException e) {
            Log.w(TAG, "[CallKeepModule][fetchStoredSettings] exception: " + e);
        }
    }

    private class VoiceBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            ConstraintsMap args = new ConstraintsMap();
            Map<String, Object> attributeMap = (Map<String, Object>) intent.getSerializableExtra(EXTRA_CALL_ATTRIB);

            switch (Objects.requireNonNull(intent.getAction())) {
                case ACTION_END_CALL:
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepPerformEndCallAction", args);
                    break;
                case ACTION_REJECT_CALL:
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepPerformRejectCallAction", args);
                    break;
                case ACTION_ANSWER_CALL:
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    args.putString("handle", (String) attributeMap.get(EXTRA_CALL_NUMBER));
                    args.putString("name", (String) attributeMap.get(EXTRA_CALLER_NAME));
                    args.putMap("additionalData", (Map<String, Object>) attributeMap.get(EXTRA_CALL_DATA));
                    sendEventToFlutter("CallKeepPerformAnswerCallAction", args);
                    break;
                case ACTION_INCOMING_CALL:
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    args.putString("handle", (String) attributeMap.get(EXTRA_CALL_NUMBER));
                    args.putString("name", (String) attributeMap.get(EXTRA_CALLER_NAME));
                    args.putMap("additionalData", (Map<String, Object>) attributeMap.get(EXTRA_CALL_DATA));
                    sendEventToFlutter("CallKeepShowIncomingCallAction", args);
                    break;
                case ACTION_ONGOING_CALL:
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    args.putString("handle", (String) attributeMap.get(EXTRA_CALL_NUMBER));
                    args.putString("name", (String) attributeMap.get(EXTRA_CALLER_NAME));
                    args.putMap("additionalData", (Map<String, Object>) attributeMap.get(EXTRA_CALL_DATA));
                    sendEventToFlutter("CallKeepDidReceiveStartCallAction", args);
                    break;
                case ACTION_FAILED_CALL:
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    args.putString("handle", (String) attributeMap.get(EXTRA_CALL_NUMBER));
                    args.putString("name", (String) attributeMap.get(EXTRA_CALLER_NAME));
                    args.putMap("additionalData", (Map<String, Object>) attributeMap.get(EXTRA_CALL_DATA));
                    sendEventToFlutter("CallKeepDidReceiveFailedCallAction", args);
                    break;
                case ACTION_HOLD_CALL:
                    args.putBoolean("hold", true);
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepDidToggleHoldAction", args);
                    break;
                case ACTION_UNHOLD_CALL:
                    args.putBoolean("hold", false);
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepDidToggleHoldAction", args);
                    break;
                case ACTION_MUTE_CALL:
                    args.putBoolean("muted", true);
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepDidPerformSetMutedCallAction", args);
                    break;
                case ACTION_UNMUTE_CALL:
                    args.putBoolean("muted", false);
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepDidPerformSetMutedCallAction", args);
                    break;
                case ACTION_DTMF_TONE:
                    args.putString("digits", (String) attributeMap.get("DTMF"));
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepDidPerformDTMFAction", args);
                    break;
                case ACTION_AUDIO_CALL:
                    args.putString("route", (String) attributeMap.get("audioRoute"));
                    args.putString("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    sendEventToFlutter("CallKeepDidChangeAudioAction", args);
                    break;
                case ACTION_AUDIO_SESSION:
                    sendEventToFlutter("CallKeepDidActivateAudioSession", args);
                    break;
                case ACTION_CHECK_REACHABILITY:
                    sendEventToFlutter("CallKeepCheckReachability", args);
                    break;
                case ACTION_WAKE_APP:
                    Intent headlessIntent = new Intent(CallKeepModule.this.context, CallKeepBackgroundMessagingService.class);
                    headlessIntent.putExtra("callUUID", (String) attributeMap.get(EXTRA_CALL_UUID));
                    headlessIntent.putExtra("name", (String) attributeMap.get(EXTRA_CALLER_NAME));
                    headlessIntent.putExtra("handle", (String) attributeMap.get(EXTRA_CALL_NUMBER));
                    headlessIntent.putExtra("additionalData", (HashMap<?, ?>) attributeMap.get(EXTRA_CALL_DATA));
                    Log.d(TAG, "wakeUpApplication: " + attributeMap.get(EXTRA_CALL_UUID) + ", number : " + attributeMap.get(EXTRA_CALL_NUMBER) + ", displayName:" + attributeMap.get(EXTRA_CALLER_NAME));

                    ComponentName name = CallKeepModule.this.context.startService(headlessIntent);
                    if (name != null) {
                        CallKeepBackgroundMessagingService.acquireWakeLockNow(CallKeepModule.this.context);
                    }
                    break;
            }
        }
    }
}
