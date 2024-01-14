package xinlake.qrcode;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.core.util.Pair;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import xinlake.qrcode.mlkit.CameraXActivity;
import xinlake.qrcode.mlkit.processer.BarcodeScannerProcessor;
import xinlake.qrcode.mlkit.processer.VisionProcessor;

/**
 * XinlakeQrcodePlugin
 * <p>
 * 2021-12
 */
public class XinlakeQrcodePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final int ACTION_SCAN_QRCODE = 7039;

    /// The MethodChannel that will the communication between Flutter and native Android
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private ActivityPluginBinding binding;

    private int actionRequestCode = 1000;
    private final HashMap<Integer, Pair<Integer, Consumer<Object>>> activityRequests = new HashMap<>();

    private int processCount;

    private void fromCamera(MethodCall call, Result result) {
        final Number accentColor;
        final String prefix;
        final Boolean playBeep;
        final Boolean frontFace;

        try {
            accentColor = call.argument("accentColor");
            prefix = call.argument("prefix");
            playBeep = call.argument("playBeep");
            frontFace = call.argument("frontFace");
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        final Activity activity = binding.getActivity();
        final Intent intent = CameraXActivity.getScanIntent(
            activity.getApplicationContext(),
            accentColor != null ? accentColor.intValue() : null,
            prefix,
            playBeep != null ? playBeep : false,
            (frontFace != null && frontFace));

        activityRequests.put(++actionRequestCode, new Pair<>(ACTION_SCAN_QRCODE,
            object -> {
                final String codeValue = (String) object;
                result.success(codeValue);
            }));
        activity.startActivityForResult(intent, actionRequestCode);
    }

    private void readImage(MethodCall call, Result result) {
        final ArrayList<String> imageList;
        try {
            imageList = call.argument("imageList");
            if (imageList == null || imageList.isEmpty()) {
                throw new Exception();
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        // decode images
        new Thread(() -> {
            final VisionProcessor<List<String>> processor = new BarcodeScannerProcessor(
                binding.getActivity(),
                "", false);

            final ArrayList<String> codeList = new ArrayList<>();
            processCount = imageList.size();

            for (String image : imageList) {
                processor.detect(Uri.fromFile(new File(image)), barcodes -> {
                    if (barcodes.size() > 0) {
                        codeList.addAll(barcodes);
                    }
                    if (--processCount < 1) {
                        processor.dispose();

                        // send results
                        binding.getActivity().runOnUiThread(() -> result.success(codeList));
                    }
                });
            }
        }).start();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "fromCamera":
                fromCamera(call, result);
                break;
            case "readImage":
                readImage(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "xinlake_qrcode");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    // ActivityAware -------------------------------------------------------------------------------
    private final PluginRegistry.ActivityResultListener handleActivityResult =
        (requestCode, resultCode, data) -> {
            Pair<Integer, Consumer<Object>> action = activityRequests.remove(requestCode);
            if (action == null) {
                return false;
            }

            assert action.first != null;
            assert action.second != null;

            if (action.first == ACTION_SCAN_QRCODE) {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    // read code
                    final String barcode = CameraXActivity.getScanResult(data);
                    action.second.accept(barcode);
                    return true;
                }
            }

            // user canceled
            action.second.accept(null);
            return true;
        };

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        binding.addActivityResultListener(handleActivityResult);
        this.binding = binding;
    }
    @Override
    public void onDetachedFromActivity() {
        binding.removeActivityResultListener(handleActivityResult);
        binding = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        binding.addActivityResultListener(handleActivityResult);
        this.binding = binding;
    }
    @Override
    public void onDetachedFromActivityForConfigChanges() {
        binding.removeActivityResultListener(handleActivityResult);
        binding = null;
    }
}
