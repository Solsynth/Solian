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

import android.annotation.SuppressLint;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;

import androidx.annotation.Nullable;

public class CallKeepBackgroundMessagingService extends Service {
  private static final String TAG = "FLT:CallKeepService";
  private static @Nullable PowerManager.WakeLock sWakeLock;
  /**
   * Acquire a wake lock to ensure the device doesn't go to sleep while processing background tasks.
   */
  @SuppressLint("WakelockTimeout")
  public static void acquireWakeLockNow(Context context) {
    if (sWakeLock == null || !sWakeLock.isHeld()) {
      PowerManager powerManager = (PowerManager) context.getSystemService(POWER_SERVICE);
      sWakeLock =
              powerManager.newWakeLock(
                      PowerManager.PARTIAL_WAKE_LOCK, CallKeepBackgroundMessagingService.class.getCanonicalName());
      sWakeLock.setReferenceCounted(false);
      sWakeLock.acquire();
    }
  }

  @Nullable
  @Override
  public IBinder onBind(Intent intent) {
    Log.d(TAG, "wakeUpApplication: " + intent.getStringExtra(CallKeepConstants.EXTRA_CALL_UUID) +
            ", number : " + intent.getStringExtra(CallKeepConstants.EXTRA_CALL_NUMBER) +
            ", displayName:" + intent.getStringExtra(CallKeepConstants.EXTRA_CALLER_NAME));
    //TODO: not implemented
    return null;
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    if (sWakeLock != null) {
      sWakeLock.release();
    }
  }
}
