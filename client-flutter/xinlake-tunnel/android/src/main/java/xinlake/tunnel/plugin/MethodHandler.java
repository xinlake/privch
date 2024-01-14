package xinlake.tunnel.plugin;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.net.TrafficStats;
import android.net.VpnService;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.core.util.Pair;

import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import xinlake.tunnel.aidl.ITunnelMethod;
import xinlake.tunnel.core.shadowsocks.SSService;

public class MethodHandler implements
    PluginRegistry.ActivityResultListener,
    MethodChannel.MethodCallHandler {
    private static final int ACTION_ESTABLISH_VPN = 1;

    // activity actions
    private int activityActionCode = 7039;
    private final HashMap<Integer, Pair<Integer, Consumer<Boolean>>> activityActions = new HashMap<>();

    private int applicationUid;
    private final ArrayList<Long> trafficBytes = new ArrayList<>(2);

    private ActivityPluginBinding binding;
    private EventHandler eventHandler;

    // service
    private ITunnelMethod tunnelMethod;
    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            tunnelMethod = ITunnelMethod.Stub.asInterface(service);
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            tunnelMethod = null;
        }

        @Override
        public void onBindingDied(ComponentName name) {
            tunnelMethod = null;
        }
    };

    private final BroadcastReceiver tunnelReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final Activity activity = binding.getActivity();
            final int status = intent.getIntExtra("status", 0);

            if (status > 0) {
                activity.runOnUiThread(() -> eventHandler.notifyStateChanged(status));
            }
        }
    };

    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    public void attachedToActivity(ActivityPluginBinding binding, EventHandler eventHandler) {
        // bind service and register receiver
        final Context context = binding.getActivity().getApplicationContext();
        context.bindService(
            new Intent(context, SSService.class),
            serviceConnection, Context.BIND_AUTO_CREATE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(tunnelReceiver,
                new IntentFilter("xinlake.tunnel.broadcast"),
                Context.RECEIVER_NOT_EXPORTED);
        } else {
            context.registerReceiver(tunnelReceiver,
                new IntentFilter("xinlake.tunnel.broadcast"));
        }

        applicationUid = binding.getActivity().getApplicationInfo().uid;
        binding.addActivityResultListener(this);

        this.binding = binding;
        this.eventHandler = eventHandler;
    }

    public void detachedFromActivity() {
        binding.removeActivityResultListener(this);

        // unregister receiver, unbind and stop service
        final Context context = binding.getActivity().getApplicationContext();
        context.unregisterReceiver(tunnelReceiver);

        try {
            context.unbindService(serviceConnection);
            context.stopService(new Intent(context, SSService.class));
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    private void getTrafficBytes(MethodChannel.Result result) {
        trafficBytes.clear();
        trafficBytes.add(TrafficStats.getUidTxBytes(applicationUid));
        trafficBytes.add(TrafficStats.getUidRxBytes(applicationUid));
        result.success(trafficBytes);
    }

    private void getState(MethodChannel.Result result) {
        final int state;
        try {
            state = tunnelMethod.getState();
        } catch (Exception exception) {
            exception.printStackTrace();
            result.error("Invalid parameters", null, null);
            return;
        }

        result.success(state);
    }

    private void connect(MethodCall call, MethodChannel.Result result) {
        final Integer port;
        final String address;
        final String password;
        final String encrypt;

        // check parameters
        try {
            port = call.argument("port");
            address = call.argument("address");
            password = call.argument("password");
            encrypt = call.argument("encrypt");
            if (port == null || address == null ||
                password == null || encrypt == null) {
                throw new Exception();
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        // establish a VPN connection
        activityActions.put(++activityActionCode, new Pair<>(ACTION_ESTABLISH_VPN, prepared -> {
            if (prepared) {
                try {
                    tunnelMethod.startService(port, address, password, encrypt);
                } catch (Exception exception) {
                    exception.printStackTrace();
                }
            }

            result.success(null);
        }));

        final Activity activity = binding.getActivity();
        Intent intent = VpnService.prepare(activity.getApplicationContext());
        if (intent != null) {
            activity.startActivityForResult(intent, activityActionCode);
        } else {
            onActivityResult(activityActionCode, Activity.RESULT_OK, null);
        }
    }

    private void stopTunnel(MethodChannel.Result result) {
        try {
            tunnelMethod.stopService();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        result.success(null);
    }

    private void updateSettings(MethodCall call, MethodChannel.Result result) {
        final Number socksPort;
        final Number dnsLocalPort;
        final String dnsRemoteAddress;

        // check parameters
        try {
            socksPort = call.argument("socksPort");
            dnsLocalPort = call.argument("dnsLocalPort");
            dnsRemoteAddress = call.argument("dnsRemoteAddress");
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        if (socksPort != null) {
            try {
                tunnelMethod.setSocksPort(socksPort.intValue());
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        if (dnsLocalPort != null) {
            try {
                tunnelMethod.setDnsLocalPort(dnsLocalPort.intValue());
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        if (dnsRemoteAddress != null) {
            try {
                tunnelMethod.setDnsRemoteAddress(dnsRemoteAddress);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        // send result
        result.success(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getTrafficBytes" -> getTrafficBytes(result);
            case "getState" -> getState(result);
            case "connect" -> connect(call, result);
            case "stopTunnel" -> stopTunnel(result);
            case "updateSettings" -> updateSettings(call, result);
            default -> result.notImplemented();
        }
    }

    /**
     * @return true if the result has been handled.
     */
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Pair<Integer, Consumer<Boolean>> action = activityActions.remove(requestCode);
        if (action != null) {
            assert action.first != null;
            assert action.second != null;

            if (action.first == ACTION_ESTABLISH_VPN) {
                // care about resultCode only
                boolean prepared = resultCode == Activity.RESULT_OK;
                action.second.accept(prepared);
            }

            return true;
        }

        return false;
    }
}
