package privch.flutter;

import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.net.VpnService;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.arch.core.util.Function;
import androidx.core.util.Pair;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

import armoury.Armoury;
import armoury.common.Logger;
import armoury.mobile.picker.ImagePickActivity;
import armoury.vision.CameraXActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import privch.core.PrivChData;
import privch.core.PrivChPreference;
import privch.flutter.channel.DataMethod;
import privch.flutter.channel.PlatformEvent;
import privch.flutter.channel.VpnMethod;
import privch.flutter.channel.XinMethod;

/**
 * 2021-04
 */
public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity.";

    private static final String ACTION_CAPTURE_IMAGE = "capture-image-action";
    private static final String ACTION_PICK_IMAGE = "pick-image-action";
    private static final String ACTION_ESTABLISH_VPN = "establish-vpn-action";

    private int actionCode = 100;
    private final HashMap<Integer, Pair<String, Function<Object, Void>>> actionList = new HashMap<>();

    private final DataMethod.Listener dataListener = new DataMethod.Listener() {
        @Override
        public void onPickQrCamera(Integer facing, String analyzer, String prefix,
                                   Function<Object, Void> callback) {
            Intent intent = new Intent(MainActivity.this, CameraXActivity.class);
            if (facing != null) {
                intent.putExtra(CameraXActivity.KEY_FACING, facing.intValue());
            }
            intent.putExtra(CameraXActivity.KEY_ANALYZER, analyzer);
            intent.putExtra(CameraXActivity.KEY_PREFIX, prefix);

            ++actionCode;
            actionList.put(actionCode, new Pair<>(ACTION_CAPTURE_IMAGE, callback));
            startActivityForResult(intent, actionCode);
        }

        @Override
        public void onPickQrImage(String title, Long primaryColor, Integer maxSelect,
                                  Function<Object, Void> callback) {
            final Intent intent = new Intent(MainActivity.this, ImagePickActivity.class);
            intent.putExtra(ImagePickActivity.KEY_TITLE, title);
            if (primaryColor != null) {
                intent.putExtra(ImagePickActivity.KEY_PRIMARY_COLOR, primaryColor.intValue());
            }
            if (maxSelect != null) {
                intent.putExtra(ImagePickActivity.KEY_MAX_SELECT, maxSelect);
            }

            ++actionCode;
            actionList.put(actionCode, new Pair<>(ACTION_PICK_IMAGE, callback));
            startActivityForResult(intent, actionCode);
        }
    };

    public final VpnMethod.Listener vpnListener = callback -> {
        Intent intent = VpnService.prepare(getApplicationContext());
        if (intent != null) {
            ++actionCode;
            actionList.put(actionCode, new Pair<>(ACTION_ESTABLISH_VPN, callback));
            startActivityForResult(intent, actionCode);
        } else {
            callback.apply(true);
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        Pair<String, Function<Object, Void>> action = actionList.remove(requestCode);
        if (action == null || action.first == null || action.second == null) {
            Logger.write(TAG + "onActivityResult", "Invalid arguments");
            return;
        }

        if (action.first.equals(ACTION_CAPTURE_IMAGE)) {
            String qrCode = null;
            if (resultCode == RESULT_OK && data != null) {
                qrCode = data.getStringExtra(CameraXActivity.KEY_RESULT);
            }

            action.second.apply(qrCode);
        } else if (action.first.equals(ACTION_PICK_IMAGE)) {
            ArrayList<Uri> uriList = null;
            if (resultCode == RESULT_OK && data != null) {
                uriList = data.getParcelableArrayListExtra(ImagePickActivity.KEY_RESULT);
            }

            action.second.apply(uriList);
        } else if (action.first.equals(ACTION_ESTABLISH_VPN)) {
            boolean prepared = (resultCode == RESULT_OK);
            action.second.apply(prepared);
        }
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        // handle uiMode changes
        int nightMode = newConfig.uiMode & Configuration.UI_MODE_NIGHT_MASK;
        if (nightMode == Configuration.UI_MODE_NIGHT_YES) {
            PrivChPlatform.getInstance().platformEvent.platformConfigChanged(true);
        } else if (nightMode == Configuration.UI_MODE_NIGHT_NO) {
            PrivChPlatform.getInstance().platformEvent.platformConfigChanged(false);
        }
    }

    /* super.onCreate(savedInstanceState) invoke this method
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // start service
        startService(new Intent(getApplicationContext(), privch.tunnel.shadowsocks.SSService.class));

        // initialises
        Armoury.init(getApplicationContext(), new File(getFilesDir(), "privch.log"));
        PrivChData.create(getApplicationContext(), getFilesDir() + "/privch.db");
        PrivChPreference.getPreferences(getApplicationContext());

        // init platform channels
        PrivChPlatform.create(this, dataListener, vpnListener);

        /* register platform views
        flutterEngine.getPlatformViewsController().getRegistry()
            .registerViewFactory(ImageFactory.typeId, new ImageFactory());
        */

        // method channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), XinMethod.CHANNEL_NAME)
            .setMethodCallHandler(PrivChPlatform.getInstance().xinMethod);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), DataMethod.CHANNEL_NAME)
            .setMethodCallHandler(PrivChPlatform.getInstance().dataMethod);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VpnMethod.CHANNEL_NAME)
            .setMethodCallHandler(PrivChPlatform.getInstance().vpnMethod);
        // event channel
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PlatformEvent.CHANNEL_NAME)
            .setStreamHandler(PrivChPlatform.getInstance().platformEvent);
    }

    @Override
    public void onDestroy() {
        PrivChPlatform.dispose();
        PrivChData.dispose();

        stopService(new Intent(getApplicationContext(), privch.tunnel.shadowsocks.SSService.class));
        super.onDestroy();
    }
}
