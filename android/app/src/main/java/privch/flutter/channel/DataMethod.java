package privch.flutter.channel;

import android.app.Activity;
import android.content.SharedPreferences;
import android.net.Uri;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.arch.core.util.Function;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import armoury.common.Logger;
import armoury.mobile.picker.ImagePickActivity;
import armoury.vision.CameraXActivity;
import armoury.vision.ZXingDecoder;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import privch.core.PrivChData;
import privch.core.PrivChPreference;
import privch.core.data.Shadowsocks;

/**
 * 2021-04-26
 */
public class DataMethod implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL_NAME = "data-method";
    private static final String TAG = "DataMethod.";

    private final Activity activity;
    private final PrivChData database;
    private final Listener listener;

    public DataMethod(@NonNull Activity activity, @NonNull Listener listener) {
        this.activity = activity;
        this.listener = listener;
        this.database = PrivChData.getInstance();
    }

    /**
     * Handles the specified method call received from Flutter.
     */
    @Override
    @MainThread
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            // database-shadowsocks
            case "getShadowsocksCount":
                getShadowsocksCount(result);
                break;

            case "getAllShadowsocks":
                getAllShadowsocks(result);
                break;

            case "updateAllShadowsocks":
                updateAllShadowsocks(call, result);
                break;

            case "insertShadowsocks":
                insertShadowsocks(call, result);
                break;

            case "deleteShadowsocks":
                deleteShadowsocks(call, result);
                break;

            case "importQrCamera":
                importQrCamera(call, result);
                break;

            case "importQrImage":
                importQrImage(call, result);
                break;

            // develop
            case "devGenerateShadowsocks":
                devGenerateShadowsocks(call, result);
                break;

            // database-preference
            case "readPreference":
                readPreference(result);
                break;

            case "writePreference":
                writePreference(call, result);
                break;

            // not implement
            default:
                result.notImplemented();
                break;
        }
    }

    // database shadowsocks ------------------------------------------------------------------------
    private void getShadowsocksCount(@NonNull MethodChannel.Result result) {
        new Thread(() -> {
            final int count = database.shadowsocksDao().getCount();

            // send result
            activity.runOnUiThread(() -> result.success(count));
        }).start();
    }

    private void getAllShadowsocks(@NonNull MethodChannel.Result result) {
        new Thread(() -> {
            List<Shadowsocks> ssList = database.shadowsocksDao().getAll();
            final List<HashMap<String, Object>> mapList = Shadowsocks.toMap(ssList);

            // send result
            activity.runOnUiThread(() -> result.success(mapList));
        }).start();
    }

    @SuppressWarnings("unchecked")
    private void updateAllShadowsocks(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (!(call.arguments instanceof ArrayList)) {
            result.success(null);
            Logger.write(TAG + "updateAllShadowsocks", "Invalid arguments");
            return;
        }

        new Thread(() -> {
            List<HashMap<String, Object>> mapList = (List<HashMap<String, Object>>) call.arguments;
            final List<Shadowsocks> ssList = Shadowsocks.fromMap(mapList);
            database.shadowsocksDao().updateAll(ssList);

            // send result
            activity.runOnUiThread(() -> result.success(ssList.size()));
        }).start();
    }

    @SuppressWarnings("unchecked")
    private void insertShadowsocks(MethodCall call, MethodChannel.Result result) {
        if (!(call.arguments instanceof HashMap)) {
            result.success(null);
            Logger.write(TAG + "insertShadowsocks", "Invalid arguments");
            return;
        }

        new Thread(() -> {
            HashMap<String, Object> hashMap = (HashMap<String, Object>) call.arguments;
            Shadowsocks ss = Shadowsocks.fromMap(hashMap);

            // insert data and send result
            if (ss != null) {
                final long id = database.shadowsocksDao().insert(ss);
                activity.runOnUiThread(() -> result.success(id));
            } else {
                activity.runOnUiThread(() -> result.success(null));
            }
        }).start();
    }

    private void deleteShadowsocks(MethodCall call, MethodChannel.Result result) {
        final Integer id = call.argument("id");
        if (id == null) {
            result.success(null);
            Logger.write(TAG + "deleteShadowsocks", "Invalid arguments");
            return;
        }

        new Thread(() -> {
            database.shadowsocksDao().delete(id);

            // send bool result
            activity.runOnUiThread(() -> result.success(true));
        }).start();
    }

    private void importQrCamera(MethodCall call, MethodChannel.Result result) {
        final Integer facing = call.argument(CameraXActivity.KEY_FACING);
        final String analyzer = call.argument(CameraXActivity.KEY_ANALYZER);
        final String prefix = call.argument(CameraXActivity.KEY_PREFIX);

        listener.onPickQrCamera(facing, analyzer, prefix, text -> {
            String qrCode = (String) text;
            if (qrCode != null && !qrCode.isEmpty()) {
                // add ss to database and return it to the dart side
                final Shadowsocks ss = Shadowsocks.fromQrCode(qrCode);
                if (ss != null) {
                    new Thread(() -> {
                        database.shadowsocksDao().insert(ss);
                        activity.runOnUiThread(() -> result.success(Shadowsocks.toMap(ss)));
                    }).start();

                    return null;
                }
            }

            // canceled or not found or invalid ss code
            result.success(null);
            return null;
        });
    }

    private void importQrImage(MethodCall call, MethodChannel.Result result) {
        final String title = call.argument(ImagePickActivity.KEY_TITLE);
        final Long primaryColor = call.argument(ImagePickActivity.KEY_PRIMARY_COLOR);
        final Integer maxSelect = call.argument(ImagePickActivity.KEY_MAX_SELECT);

        listener.onPickQrImage(title, primaryColor, maxSelect, images -> {
            @SuppressWarnings("unchecked")
            final ArrayList<Uri> uriList = (ArrayList<Uri>) images;
            if (uriList != null && uriList.size() > 0) {
                new Thread(() -> {
                    // decode image and add the ss to database
                    ArrayList<Shadowsocks> ssList = new ArrayList<>();
                    uriList.forEach(uri -> {
                        String qrCode = ZXingDecoder.decodeImage(activity, uri);
                        Shadowsocks ss = Shadowsocks.fromQrCode(qrCode);
                        if (ss != null) {
                            database.shadowsocksDao().insert(ss);
                            ssList.add(ss);
                        }
                    });

                    // send ss list
                    final List<HashMap<String, Object>> mapList = Shadowsocks.toMap(ssList);
                    activity.runOnUiThread(() -> result.success(mapList));
                }).start();

                return null;
            }

            // canceled or invalid selection
            result.success(null);
            return null;
        });
    }

    // develop
    private void devGenerateShadowsocks(MethodCall call, MethodChannel.Result result) {
        final Integer count = call.argument("count");
        if (count == null) {
            result.success(null);
            Logger.write(TAG + "devGenerateShadowsocks", "Invalid arguments");
            return;
        }

        new Thread(() -> {
            if (count > 0) {
                List<Shadowsocks> ssList = Shadowsocks.random(count);
                database.shadowsocksDao().insertAll(ssList);
            }

            // send result
            activity.runOnUiThread(() -> result.success(count));
        }).start();
    }

    // preference ----------------------------------------------------------------------------------
    private void readPreference(MethodChannel.Result result) {
        // load preference
        SharedPreferences preferences = PrivChPreference.getPreferences(activity.getApplicationContext());
        final int currentServerId = preferences.getInt(PrivChPreference.keyCurrentServerId, -1);
        final int themeSetting = preferences.getInt(PrivChPreference.keyThemeSetting, 0);
        final int proxyPort = preferences.getInt(PrivChPreference.keyProxyPort, PrivChPreference.defProxyPort);
        final int localDnsPort = preferences.getInt(PrivChPreference.keyLocalDnsPort, PrivChPreference.defLocalDnsPort);
        final String remoteDnsAddress = preferences.getString(PrivChPreference.keyRemoteDnsAddress, PrivChPreference.defRemoteDnsAddress);

        // send preference
        final HashMap<String, Object> hashMap = new HashMap<>();
        hashMap.put("current-server-id", currentServerId);
        hashMap.put("theme-setting", themeSetting);
        hashMap.put("proxy-port", proxyPort);
        hashMap.put("local-dns-port", localDnsPort);
        hashMap.put("remote-dns-address", remoteDnsAddress);

        // send result
        result.success(hashMap);
    }

    private void writePreference(MethodCall call, MethodChannel.Result result) {
        final Integer currentServerId = call.argument("current-server-id");
        final Integer themeSetting = call.argument("theme-setting");
        final Integer proxyPort = call.argument("proxy-port");
        final Integer localDnsPort = call.argument("local-dns-port");
        final String remoteDnsAddress = call.argument("remote-dns-address");

        // write preference
        SharedPreferences preferences = PrivChPreference.getPreferences(activity.getApplicationContext());
        SharedPreferences.Editor editor = preferences.edit();

        int applyCount = 0;
        if (themeSetting != null) {
            editor.putInt(PrivChPreference.keyThemeSetting, themeSetting);
            ++applyCount;
        }
        if (currentServerId != null) {
            editor.putInt(PrivChPreference.keyCurrentServerId, currentServerId);
            ++applyCount;
        }
        if (proxyPort != null) {
            editor.putInt(PrivChPreference.keyProxyPort, proxyPort);
            ++applyCount;
        }
        if (localDnsPort != null) {
            editor.putInt(PrivChPreference.keyLocalDnsPort, localDnsPort);
            ++applyCount;
        }
        if (remoteDnsAddress != null) {
            editor.putString(PrivChPreference.keyRemoteDnsAddress, remoteDnsAddress);
            ++applyCount;
        }
        editor.apply();

        // send result
        result.success(applyCount);
    }

    // listener ------------------------------------------------------------------------------------
    public interface Listener {
        void onPickQrCamera(Integer facing, String analyzer, String prefix,
                            Function<Object, Void> callback);
        void onPickQrImage(String title, Long primaryColor, Integer maxSelect,
                           Function<Object, Void> callback);
    }
}
