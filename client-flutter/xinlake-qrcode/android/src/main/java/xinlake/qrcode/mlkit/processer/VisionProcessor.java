/*
 * Copyright 2020 Google LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package xinlake.qrcode.mlkit.processer;

import android.content.Context;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.Image;
import android.media.ToneGenerator;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageProxy;
import androidx.core.util.Consumer;

import com.google.mlkit.vision.common.InputImage;

import xinlake.qrcode.mlkit.GraphicOverlay;

/*
 * Multi code detection is not necessary
 */
public abstract class VisionProcessor<T> {
    public abstract void detect(ImageProxy imageProxy, @NonNull GraphicOverlay graphicOverlay,
                                @NonNull Consumer<T> onDetected);
    public abstract void detect(Uri uri, @NonNull Consumer<T> onCompleted);
    public abstract void dispose();

    protected final Context context;
    protected final ToneGenerator toneGenerator;
    private AudioFocusRequest audioFocusRequest;

    protected VisionProcessor(Context context) {
        this.context = context;
        toneGenerator = new ToneGenerator(AudioManager.STREAM_MUSIC, ToneGenerator.MAX_VOLUME);
    }

    protected void playBeep() {
        requestAudioFocus();
        new Handler(Looper.getMainLooper()).postDelayed(
            this::releaseAudioFocus, 280);
        toneGenerator.startTone(ToneGenerator.TONE_DTMF_D, 260);
    }

    private void requestAudioFocus() {
        audioFocusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            .setOnAudioFocusChangeListener(focusChange -> {
                // ignored
            })
            .setAcceptsDelayedFocusGain(true)
            .setWillPauseWhenDucked(true)
            .build();

        AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        audioManager.requestAudioFocus(audioFocusRequest);
    }

    private void releaseAudioFocus() {
        if (audioFocusRequest != null) {
            AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
            audioManager.abandonAudioFocusRequest(audioFocusRequest);
            audioFocusRequest = null;
        }
    }

    @Nullable
    @ExperimentalGetImage
    protected static InputImage getImage(@NonNull ImageProxy imageProxy) {
        final Image image = imageProxy.getImage();
        if (image != null) {
            return InputImage.fromMediaImage(
                image,
                imageProxy.getImageInfo().getRotationDegrees());
        }
        return null;
    }
}
