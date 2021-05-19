package privch.flutter.channel;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.net.TrafficStats;
import android.os.Build;
import android.view.Window;
import android.widget.Toast;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;

import java.util.HashMap;

import armoury.common.Logger;
import armoury.network.GeoLocation;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import xinlake.privch.flutter.R;

/**
 * 2021-04-26
 */
public class XinMethod implements MethodChannel.MethodCallHandler {
    private static final String TAG = "XinMethod.";
    public static final String CHANNEL_NAME = "xinlake-method";

    private final Activity activity;
    private final GeoLocation geoLocation;

    public XinMethod(@NonNull Activity activity) {
        this.activity = activity;
        geoLocation = new GeoLocation();
    }

    @Override
    @MainThread
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            // application
            case "getPackageInfo":
                getPackageInfo(result);
                break;

            case "checkSelfPermission":
                checkSelfPermission(call, result);
                break;

            // system
            case "showToast":
                showToast(call, result);
                break;

            case "getNightMode":
                getNightMode(result);
                break;

            case "setNavigationBar":
                setNavigationBar(call, result);
                break;

            // network
            case "requestGeoLocation":
                requestGeoLocation(call, result);
                break;

            case "getSelfTrafficBytes":
                getSelfTrafficBytes(result);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    // application ---------------------------------------------------------------------------------
    private void getPackageInfo(@NonNull MethodChannel.Result result) {
        PackageInfo packageInfo = null;
        try {
            String packageName = activity.getPackageName();
            packageInfo = activity.getPackageManager().getPackageInfo(packageName, 0);
        } catch (Exception exception) {
            Logger.write(TAG + "getPackageInfo", exception.getMessage());
        }

        if (packageInfo == null) {
            result.success(null);
            return;
        }

        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("versionName", packageInfo.versionName);
        hashMap.put("versionCode", packageInfo.versionCode);
        if (Build.VERSION.SDK_INT > 28) {
            hashMap.put("longVersionCode", packageInfo.getLongVersionCode());
        }
        // xinlake special
        hashMap.put("buildHost", activity.getString(R.string.gradle_build_host));
        hashMap.put("buildUser", activity.getString(R.string.gradle_build_user));
        hashMap.put("buildTime", activity.getString(R.string.gradle_build_time));
        //hashMap.put("buildHost", BuildConfig.buildHost);
        //hashMap.put("buildUser", BuildConfig.buildUser);
        //hashMap.put("buildTime", BuildConfig.buildTime);

        // send result
        result.success(hashMap);
    }

    private void checkSelfPermission(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String permission = call.argument("permission");
        if (permission == null || permission.isEmpty()) {
            result.success(null);
            Logger.write(TAG + "checkPermission", "Invalid arguments");
            return;
        }

        final boolean granted =
            (activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED);
        result.success(granted);
    }

    // system --------------------------------------------------------------------------------------
    private void showToast(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String message = call.argument("message");
        final Integer duration = call.argument("duration");
        if (message == null) {
            result.success(null);
            Logger.write(TAG + "showToast", "Invalid arguments");
            return;
        }

        // show toast
        int toastDuration = duration != null ? duration : Toast.LENGTH_SHORT;
        Toast.makeText(activity, message, toastDuration).show();

        // send complete
        result.success(null);
    }

    private void getNightMode(MethodChannel.Result result) {
        Boolean nightMode;

        int mode = activity.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
        if (mode == Configuration.UI_MODE_NIGHT_YES) {
            nightMode = true;
        } else if (mode == Configuration.UI_MODE_NIGHT_NO) {
            nightMode = false;
        } else {
            nightMode = null;
        }

        // send result
        result.success(nightMode);
    }

    private void setNavigationBar(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Long color = call.argument("color");
        Long dividerColor = call.argument("dividerColor");
        Integer animate = call.argument("animate");
        if (color == null) {
            result.success(null);
            Logger.write(TAG + "setNavigationBar", "Invalid arguments");
            return;
        }

        // check window
        Window window = activity.getWindow();
        if (window == null) {
            result.success(null);
            Logger.write(TAG + "setNavigationBar", "Window is null");
            return;
        }

        // set navigation bar.
        if (animate != null && animate > 0) {
            ValueAnimator colorAnimation = ValueAnimator.ofArgb(window.getNavigationBarColor(), color.intValue());
            colorAnimation.addUpdateListener(animation -> window.setNavigationBarColor((Integer) animation.getAnimatedValue()));
            colorAnimation.setDuration(animate);
            colorAnimation.start();
        } else {
            window.setNavigationBarColor(color.intValue());
        }

        if (dividerColor != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.setNavigationBarDividerColor(dividerColor.intValue());
        }

        result.success(null);
    }

    // networks ------------------------------------------------------------------------------------
    private void requestGeoLocation(MethodCall call, MethodChannel.Result result) {
        final String ip = call.argument("ip");
        if (ip == null || ip.isEmpty()) {
            result.success(null);
            Logger.write(TAG + "requestGeoLocation", "Invalid arguments");
            return;
        }

        new Thread(() -> {
            final String ipLocation = geoLocation.fromWebsite(ip);
            activity.runOnUiThread(() -> result.success(ipLocation));
        }).start();
    }

    private void getSelfTrafficBytes(MethodChannel.Result result) {
        int uid = activity.getApplicationInfo().uid;
        long uidTotalTx = TrafficStats.getUidTxBytes(uid);
        long uidTotalRx = TrafficStats.getUidRxBytes(uid);

        HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("rx", uidTotalRx);
        hashMap.put("tx", uidTotalTx);
        result.success(hashMap);
    }
}
