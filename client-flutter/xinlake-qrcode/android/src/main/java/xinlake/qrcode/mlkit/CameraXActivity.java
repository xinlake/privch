package xinlake.qrcode.mlkit;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.WindowMetrics;
import android.widget.ImageButton;

import androidx.activity.ComponentActivity;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.camera.core.AspectRatio;
import androidx.camera.core.CameraInfoUnavailableException;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory;

import java.util.List;

import xinlake.qrcode.R;
import xinlake.qrcode.mlkit.processer.BarcodeScannerProcessor;
import xinlake.qrcode.mlkit.processer.VisionProcessor;

/**
 * Live preview demo app for ML Kit APIs using CameraX.
 * <a href="https://github.com/googlesamples/mlkit/tree/master/android/vision-quickstart">vision-quickstart</a>.
 * <p>
 * 2021-12
 */
public final class CameraXActivity extends ComponentActivity {
    private ProcessCameraProvider cameraProvider;
    private CameraSelector cameraSelector;
    private VisionProcessor<List<String>> imageProcessor;
    private boolean needUpdateOverlayInfo;

    // parameters
    private int accentColor;
    private int lensFacing;
    private String codePrefix;
    private boolean playBeep;

    public static Intent getScanIntent(Context context, Integer accentColor,
                                       String prefix, boolean playBeep, boolean frontFace) {
        Intent intent = new Intent(context, CameraXActivity.class)
            .putExtra("prefix", prefix)
            .putExtra("playBeep", playBeep)
            .putExtra("facing", frontFace
                ? CameraSelector.LENS_FACING_FRONT
                : CameraSelector.LENS_FACING_BACK);

        if (accentColor != null) {
            intent.putExtra("accentColor", accentColor);
        }

        return intent;
    }

    @Nullable
    public static String getScanResult(Intent intent) {
        return intent.getStringExtra("barcode");
    }

    private void getStartParameter() {
        // get parameters.
        final Intent intent = getIntent();
        accentColor = intent.getIntExtra("accentColor", 0xFF009688);
        codePrefix = intent.getStringExtra("prefix");
        playBeep = intent.getBooleanExtra("playBeep", false);
        lensFacing = intent.getIntExtra("facing", CameraSelector.LENS_FACING_BACK);
    }

    private void setResultAndFinish(List<String> codeList) {
        Intent intent = new Intent()
            .putExtra("barcode", codeList.get(0));
        setResult(Activity.RESULT_OK, intent);
        finish();
    }

    private void bindAllCameraUseCases() {
        if (cameraProvider == null) {
            return;
        }

        /* Set up preview use case
         */
        final int screenAspectRatio;
        final int displayRotation;

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            final WindowMetrics metrics = getWindowManager().getCurrentWindowMetrics();
            final Rect bounds = metrics.getBounds();

            screenAspectRatio = aspectRatio(bounds.width(), bounds.height());
            displayRotation = getDisplay().getRotation();
        } else {
            final DisplayMetrics metrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(metrics);

            screenAspectRatio = aspectRatio(metrics.widthPixels, metrics.heightPixels);
            displayRotation = getWindowManager().getDefaultDisplay().getRotation();
        }

        final Preview previewUseCase = new Preview.Builder()
            .setTargetAspectRatio(screenAspectRatio)
            .setTargetRotation(displayRotation)
            .build();

        // Connect the preview use case to the previewView
        PreviewView previewView = findViewById(R.id.armouryCamera_previewView);
        previewUseCase.setSurfaceProvider(previewView.getSurfaceProvider());

        /* Set up analysis use case
        TODO: selection.
        imageProcessor = new TextRecognitionProcessor(this,
            new ChineseTextRecognizerOptions.Builder().build());
         */
        if (imageProcessor != null) {
            imageProcessor.dispose();
        }
        imageProcessor = new BarcodeScannerProcessor(this, codePrefix, playBeep);

        ImageAnalysis.Builder analysisBuilder = new ImageAnalysis.Builder();
        ImageAnalysis analysisUseCase = analysisBuilder.build();

        GraphicOverlay graphicOverlay = findViewById(R.id.armouryCamera_graphicOverlay);
        needUpdateOverlayInfo = true;

        analysisUseCase.setAnalyzer(
            // imageProcessor.processImageProxy will use another thread to run the detection underneath,
            // thus we can just runs the analyzer itself on main thread.
            ContextCompat.getMainExecutor(this),
            imageProxy -> {
                if (needUpdateOverlayInfo) {
                    boolean isImageFlipped = lensFacing == CameraSelector.LENS_FACING_FRONT;
                    int rotationDegrees = imageProxy.getImageInfo().getRotationDegrees();
                    if (rotationDegrees == 0 || rotationDegrees == 180) {
                        graphicOverlay.setImageSourceInfo(
                            imageProxy.getWidth(), imageProxy.getHeight(), isImageFlipped);
                    } else {
                        graphicOverlay.setImageSourceInfo(
                            imageProxy.getHeight(), imageProxy.getWidth(), isImageFlipped);
                    }
                    needUpdateOverlayInfo = false;
                }
                imageProcessor.detect(imageProxy, graphicOverlay,
                    this::setResultAndFinish);
            });

        // Unbinds all use cases before trying to re-bind any of them,
        // required by CameraX API.
        cameraProvider.unbindAll();
        cameraProvider.bindToLifecycle(this, cameraSelector,
            previewUseCase, analysisUseCase);
    }

    /**
     * [androidx.camera.core.ImageAnalysisConfig] requires enum value of
     * [androidx.camera.core.AspectRatio]. Currently it has values of 4:3 & 16:9.
     * Detecting the most suitable ratio for dimensions provided in @params by counting absolute
     * of preview ratio to one of the provided values.
     */
    private int aspectRatio(int width, int height) {
        float RATIO_4_3_VALUE = 4.0f / 3.0f;
        float RATIO_16_9_VALUE = 16.0f / 9.0f;
        float previewRatio = (float) Math.max(width, height) / Math.min(width, height);
        if (Math.abs(previewRatio - RATIO_4_3_VALUE) <= Math.abs(previewRatio - RATIO_16_9_VALUE)) {
            return AspectRatio.RATIO_4_3;
        }
        return AspectRatio.RATIO_16_9;
    }

    private final View.OnClickListener onChangeFacing = (view) -> {
        if (cameraProvider == null) {
            return;
        }

        int newLensFacing = lensFacing == CameraSelector.LENS_FACING_FRONT
            ? CameraSelector.LENS_FACING_BACK
            : CameraSelector.LENS_FACING_FRONT;
        CameraSelector newCameraSelector = new CameraSelector.Builder()
            .requireLensFacing(newLensFacing)
            .build();
        try {
            if (cameraProvider.hasCamera(newCameraSelector)) {
                lensFacing = newLensFacing;
                cameraSelector = newCameraSelector;
                bindAllCameraUseCases();
            }
        } catch (CameraInfoUnavailableException exception) {
            exception.printStackTrace();
        }
    };

    @Override
    public void onResume() {
        super.onResume();
        bindAllCameraUseCases();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (imageProcessor != null) {
            imageProcessor.dispose();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getStartParameter();

        final StateListDrawable buttonBackground = new StateListDrawable() {{
            setExitFadeDuration(400);
            addState(new int[]{android.R.attr.state_pressed}, new ColorDrawable(accentColor));
            addState(new int[]{}, new ColorDrawable(Color.TRANSPARENT));
        }};

        cameraSelector = new CameraSelector.Builder()
            .requireLensFacing(lensFacing)
            .build();

        setContentView(R.layout.armoury_activity_camera);
        ImageButton facingSwitch = findViewById(R.id.armouryCamera_buttonFacing);
        facingSwitch.setBackground(buttonBackground);
        facingSwitch.setOnClickListener(onChangeFacing);

        new ViewModelProvider(this, AndroidViewModelFactory.getInstance(getApplication()))
            .get(CameraXViewModel.class)
            .getProcessCameraProvider()
            .observe(
                this,
                provider -> {
                    cameraProvider = provider;
                    // TODO: necessary? this check has been removed form the mlkit demo
                    if (checkSelfPermission(Manifest.permission.CAMERA)
                        == PackageManager.PERMISSION_GRANTED) {
                        bindAllCameraUseCases();
                    }
                });

        setResult(Activity.RESULT_CANCELED);
        registerForActivityResult(
            new ActivityResultContracts.RequestPermission(),
            granted -> {
                if (granted) {
                    bindAllCameraUseCases();
                } else {
                    // TODO: Permission Denied
                    finish();
                }
            }).launch(Manifest.permission.CAMERA);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (imageProcessor != null) {
            imageProcessor.dispose();
        }
    }
}
