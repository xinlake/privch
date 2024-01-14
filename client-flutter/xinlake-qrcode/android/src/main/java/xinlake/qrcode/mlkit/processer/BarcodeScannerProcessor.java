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
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageProxy;
import androidx.core.util.Consumer;

import com.google.android.gms.tasks.TaskExecutors;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.barcode.common.Barcode;
import com.google.mlkit.vision.common.InputImage;

import java.util.LinkedList;
import java.util.List;

import xinlake.qrcode.mlkit.GraphicOverlay;
import xinlake.qrcode.mlkit.ScopedExecutor;

/**
 * Barcode Detector Demo.
 */
public class BarcodeScannerProcessor extends VisionProcessor<List<String>> {
    private final ScopedExecutor executor;
    private final BarcodeScanner barcodeScanner;

    private final String codePrefix;
    private final boolean playBeep;

    private final List<String> resultList = new LinkedList<>();

    // Whether this processor is already shut down
    private boolean isShutdown;

    public BarcodeScannerProcessor(Context context,
                                   @Nullable String codePrefix, boolean playBeep) {
        super(context);

        this.codePrefix = codePrefix;
        this.playBeep = playBeep;

        executor = new ScopedExecutor(TaskExecutors.MAIN_THREAD);

        /* Note that if you know which format of barcode your app is dealing with, detection will be
           faster to specify the supported barcode formats one by one, e.g.
           new BarcodeScannerOptions.Builder()
               .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
               .build();
        */
        barcodeScanner = BarcodeScanning.getClient();
    }

    @Override
    @ExperimentalGetImage
    public void detect(ImageProxy imageProxy, @NonNull GraphicOverlay graphicOverlay,
                       @NonNull Consumer<List<String>> onDetected) {
        if (isShutdown) {
            imageProxy.close();
            return;
        }

        final InputImage inputImage = VisionProcessor.getImage(imageProxy);
        if (inputImage == null) {
            return;
        }

        barcodeScanner.process(inputImage)
            .addOnSuccessListener(
                executor,
                barcodeList -> {
                    graphicOverlay.clear();
                    for (Barcode barcode : barcodeList) {
                        graphicOverlay.add(new BarcodeGraphic(graphicOverlay, barcode));
                    }
                    graphicOverlay.postInvalidate();
                })
            .addOnFailureListener(
                executor,
                exception -> {
                    graphicOverlay.clear();
                    graphicOverlay.postInvalidate();
                    exception.printStackTrace();
                })
            .addOnCompleteListener(
                executor,
                task -> {
                    imageProxy.close();
                    resultList.clear();

                    for (Barcode barcode : task.getResult()) {
                        final String codeValue = barcode.getRawValue();
                        if (codeValue != null && (codePrefix == null || codeValue.startsWith(codePrefix))) {
                            resultList.add(codeValue);
                        }
                    }

                    // TODO: continues / increase?
                    if (resultList.size() > 0) {
                        if (playBeep) {
                            playBeep();
                        }
                        onDetected.accept(resultList);
                    }
                });
    }

    @Override
    public void detect(Uri uri, @NonNull Consumer<List<String>> onCompleted) {
        final InputImage inputImage;
        try {
            inputImage = InputImage.fromFilePath(context, uri);
        } catch (Exception exception) {
            exception.printStackTrace();
            return;
        }

        barcodeScanner.process(inputImage)
            .addOnFailureListener(
                executor,
                Throwable::printStackTrace)
            .addOnCompleteListener(
                executor,
                task -> {
                    resultList.clear();
                    for (Barcode barcode : task.getResult()) {
                        final String codeValue = barcode.getRawValue();
                        if (codeValue != null && (codePrefix == null || codeValue.startsWith(codePrefix))) {
                            resultList.add(codeValue);
                        }
                    }

                    // TODO: continues / increase?
                    if (resultList.size() > 0) {
                        if (playBeep) {
                            playBeep();
                        }
                    }
                    onCompleted.accept(resultList);
                });
    }

    @Override
    public void dispose() {
        executor.shutdown();
        barcodeScanner.close();

        isShutdown = true;
    }
}
