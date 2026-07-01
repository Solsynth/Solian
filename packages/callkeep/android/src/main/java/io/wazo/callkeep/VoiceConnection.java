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

import static io.wazo.callkeep.CallKeepConstants.ACTION_ANSWER_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_AUDIO_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_AUDIO_SESSION;
import static io.wazo.callkeep.CallKeepConstants.ACTION_DTMF_TONE;
import static io.wazo.callkeep.CallKeepConstants.ACTION_END_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_HOLD_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_INCOMING_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_MUTE_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_REJECT_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_UNHOLD_CALL;
import static io.wazo.callkeep.CallKeepConstants.ACTION_UNMUTE_CALL;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALLER_NAME;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALL_ATTRIB;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALL_NUMBER;
import static io.wazo.callkeep.CallKeepConstants.EXTRA_CALL_UUID;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.telecom.CallAudioState;
import android.telecom.Connection;
import android.telecom.DisconnectCause;
import android.telecom.TelecomManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class VoiceConnection extends Connection {
    private static final String TAG = "RNCK:VoiceConnection";
    private final HashMap<String, Object> connectionData;
    private final Context context;

    VoiceConnection(@NonNull Context context, @NonNull HashMap<String, Object> connectionData) {
        super();
        this.connectionData = connectionData;
        this.context = context;
        updateDisplay();
    }

    public void updateDisplay(String callerName, String handle) {
        if (handle != null) {
            connectionData.put(EXTRA_CALL_NUMBER, handle);
        }
        if (callerName != null) {
            connectionData.put(EXTRA_CALLER_NAME, callerName);
        }
        updateDisplay();
    }

    private void updateDisplay() {
        Object address = connectionData.get(EXTRA_CALL_NUMBER);
        Object name = connectionData.get(EXTRA_CALLER_NAME);
        if (address instanceof String) {
            setAddress(Uri.parse((String) address), TelecomManager.PRESENTATION_ALLOWED);
        }
        if (name instanceof String) {
            setCallerDisplayName((String) name, TelecomManager.PRESENTATION_ALLOWED);
        }
    }

    @Override
    public void onExtrasChanged(Bundle extras) {
        super.onExtrasChanged(extras);
        Map<String, String> attributeMap = (Map<String, String>) extras.getSerializable(EXTRA_CALL_ATTRIB);
        if (attributeMap != null) {
            connectionData.putAll(attributeMap);
        }
    }

    public void setMuted(boolean muted) {
        CallAudioState currentAudioState = getCurrentAudioState();
        CallAudioState newAudioState = new CallAudioState(muted,
                currentAudioState.getRoute(),
                currentAudioState.getSupportedRouteMask()
        );
        onCallAudioStateChanged(newAudioState);
    }

    public void setAudio(Integer audioRoute) {
        CallAudioState currentAudioState = getCurrentAudioState();
        CallAudioState newAudioState = new CallAudioState(
                currentAudioState.isMuted(),
                audioRoute,
                currentAudioState.getSupportedRouteMask()
        );
        onCallAudioStateChanged(newAudioState);
    }

    @Override
    public void onCallAudioStateChanged(CallAudioState state) {
        super.onCallAudioStateChanged(state);
        if (state != null) {
            if (!Objects.equals(connectionData.get("isMuted"), state.isMuted())) {
                connectionData.put("isMuted", state.isMuted());
                sendCallRequestToActivity(state.isMuted() ? ACTION_MUTE_CALL : ACTION_UNMUTE_CALL, connectionData);
            }
            if (!Objects.equals(connectionData.get("audioRoute"), state.getRoute())) {
                connectionData.put("audioRoute", state.getRoute());
                HashMap<String, Object> data = new HashMap<>(connectionData);
                data.put("audioRoute", state.getRoute());
                data.put("audioRouteName", CallAudioState.audioRouteToString(state.getRoute()));
                sendCallRequestToActivity(ACTION_AUDIO_CALL, data);
            }
        }
    }

    private CallAudioState getCurrentAudioState() {
        CallAudioState current = getCallAudioState();
        if (current != null) return current;
        throw new UnsupportedOperationException();
    }

    @Override
    public void onAnswer() {
        super.onAnswer();
        Log.d(TAG, "onAnswer called");
        Log.d(TAG, "onAnswer ignored");
    }

    @Override
    public void onAnswer(int videoState) {
        super.onAnswer(videoState);
        Log.d(TAG, "onAnswer videoState called: " + videoState);
        onAnswered();
        Log.d(TAG, "onAnswer videoState executed");
    }

    private void onAnswered() {
        initCall();
        setCurrent();
        sendCallRequestToActivity(ACTION_ANSWER_CALL, connectionData);
    }

    public void initCall() {
        setHoldableIfSupported();
        setAudioModeIsVoip(true);
        sendCallRequestToActivity(ACTION_AUDIO_SESSION, connectionData);
    }

    @Override
    public void onShowIncomingCallUi() {
        sendCallRequestToActivity(ACTION_INCOMING_CALL, connectionData);
        super.onShowIncomingCallUi();
    }

    @Override
    public void onPlayDtmfTone(char dtmf) {
        HashMap<String, Object> data = new HashMap<>(connectionData);
        data.put("DTMF", Character.toString(dtmf));
        sendCallRequestToActivity(ACTION_DTMF_TONE, data);
    }

    @Override
    public void onDisconnect() {
        super.onDisconnect();
        close(DisconnectCause.LOCAL);
        sendCallRequestToActivity(ACTION_END_CALL, connectionData);
        Log.d(TAG, "onDisconnect executed");
    }

    public void reportDisconnect(int reason, boolean notify) {
        super.onDisconnect();
        Integer causeCode = null;
        switch (reason) {
            case 1:
                causeCode = DisconnectCause.ERROR;
                break;
            case 2:
            case 5:
                causeCode = DisconnectCause.REMOTE;
                break;
            case 3:
                causeCode = DisconnectCause.BUSY;
                break;
            case 4:
                causeCode = DisconnectCause.ANSWERED_ELSEWHERE;
                break;
            case 6:
                causeCode = DisconnectCause.MISSED;
                break;
            default:
                break;
        }
        if (causeCode != null) {
            close(causeCode);
            if (notify) {
                sendCallRequestToActivity(ACTION_END_CALL, connectionData);
            }
        }
    }

    @Override
    public void onAbort() {
        super.onAbort();
        close(DisconnectCause.REJECTED);
        sendCallRequestToActivity(ACTION_END_CALL, connectionData);
        Log.d(TAG, "onAbort executed");
    }

    @Override
    public void onHold() {
        super.onHold();
        this.setOnHold();
        sendCallRequestToActivity(ACTION_HOLD_CALL, connectionData);
    }

    @Override
    public void onUnhold() {
        super.onUnhold();
        sendCallRequestToActivity(ACTION_UNHOLD_CALL, connectionData);
        setCurrent();
    }

    @Override
    public void onReject() {
        super.onReject();
        close(DisconnectCause.REJECTED);
        sendCallRequestToActivity(ACTION_REJECT_CALL, connectionData);
        Log.d(TAG, "onReject executed");
    }

    public void onStarted() {
        setCurrent();
        Log.d(TAG, "onStarted executed");
    }

    public void setCurrent() {
        setHoldableIfSupported();
        setActive();
    }

    private void setHoldableIfSupported() {
        if ((getConnectionCapabilities() & CAPABILITY_SUPPORT_HOLD) == CAPABILITY_SUPPORT_HOLD) {
            setConnectionCapabilities(getConnectionCapabilities() | CAPABILITY_HOLD);
        }
    }

    private void close(int causeCode) {
        setDisconnected(new DisconnectCause(causeCode));
        VoiceConnectionService.deinitConnection((String) connectionData.get(EXTRA_CALL_UUID));
        destroy();
    }

    /*
     * Send call request to the RNCallKeepModule
     */
    private void sendCallRequestToActivity(String action, @Nullable HashMap<String, Object> attributeMap) {
        final Handler handler = new Handler();
        handler.post(() -> {
            Intent intent = new Intent(action);
            if (attributeMap != null) {
                Bundle extras = new Bundle();
                extras.putSerializable(EXTRA_CALL_ATTRIB, attributeMap);
                intent.putExtras(extras);
            }
            LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
        });
    }


}
