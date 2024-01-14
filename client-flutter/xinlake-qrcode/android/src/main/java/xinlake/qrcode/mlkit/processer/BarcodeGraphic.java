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

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;

import com.google.mlkit.vision.barcode.common.Barcode;

import xinlake.qrcode.mlkit.GraphicOverlay;

/**
 * Graphic instance for rendering Barcode position and content information in an overlay view.
 */
class BarcodeGraphic extends GraphicOverlay.Graphic {
    private final Paint rectPaint;
    private final Barcode barcode;

    BarcodeGraphic(GraphicOverlay overlay, Barcode barcode) {
        super(overlay);
        this.barcode = barcode;

        rectPaint = new Paint();
        rectPaint.setColor(Color.MAGENTA);
        rectPaint.setStyle(Paint.Style.STROKE);
        rectPaint.setStrokeWidth(8.0F);
        rectPaint.setStrokeCap(Paint.Cap.ROUND);
        rectPaint.setStrokeJoin(Paint.Join.MITER);
    }

    /**
     * Draws the barcode block annotations for position, size, and raw value on the supplied canvas.
     * TODO: X style
     */
    @Override
    public void draw(Canvas canvas) {
        if (barcode == null) {
            throw new IllegalStateException("Attempting to draw a null barcode.");
        }

        // Draws the bounding box around the BarcodeBlock.
        Point[] points = barcode.getCornerPoints();
        if (points != null && points.length > 3) {
            Path path = new Path();

            path.moveTo(
                translateX(points[0].x),
                translateY(points[0].y));
            for (int i = 1; i < points.length; ++i) {
                path.lineTo(
                    translateX(points[i].x),
                    translateY(points[i].y));
            }
            path.lineTo(
                translateX(points[0].x),
                translateY(points[0].y));
            path.close();

            canvas.drawPath(path, rectPaint);
        }
    }
}
