package privch.flutter.channel;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.arch.core.util.Function;

import armoury.common.Logger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import privch.tunnel.IServiceEvent;
import privch.tunnel.IServiceMethod;

/**
 * 2021-04-26
 */
public class VpnMethod implements MethodChannel.MethodCallHandler {
    private static final String TAG = "VpnMethod.";
    public static final String CHANNEL_NAME = "vpn-method";

    private final Activity activity;
    private final PlatformEvent platformEvent;
    private final Listener listener;

    private IServiceMethod serviceMethod;

    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            serviceMethod = IServiceMethod.Stub.asInterface(service);
            try {
                serviceMethod.setListener(serviceEvent);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            serviceMethod = null;
        }
    };

    private final IServiceEvent serviceEvent = new IServiceEvent.Stub() {
        @Override
        public void onMessage(String message) throws RemoteException {
            activity.runOnUiThread(() -> {
                platformEvent.vpnMessage(message);
            });
        }

        @Override
        public void onServerChanged(int serverId) throws RemoteException {
            activity.runOnUiThread(() -> {
                platformEvent.vpnServerChanged(serverId);
            });
        }

        @Override
        public void onStateChanged(boolean running) throws RemoteException {
            activity.runOnUiThread(() -> {
                platformEvent.vpnStateChanged(running);
            });
        }
    };

    public VpnMethod(@NonNull Activity activity, PlatformEvent platformEvent, Listener listener) {
        this.activity = activity;
        this.listener = listener;
        this.platformEvent = platformEvent;

        // bind the vpn service
        Intent intent = new Intent(activity.getApplicationContext(), privch.tunnel.shadowsocks.SSService.class);
        activity.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }

    public void dispose() {
        activity.unbindService(serviceConnection);
    }

    @Override @MainThread
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "stopService":
                stopService(result);
                break;

            case "updateShadowsocks":
                updateShadowsocks(call, result);
                break;

            case "updateSettings":
                updateSettings(call, result);
                break;
        }
    }

    private void stopService(MethodChannel.Result result) {
        try {
            serviceMethod.stopService();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        result.success(null);
    }

    private void updateShadowsocks(MethodCall call, MethodChannel.Result result) {
        final Integer id = call.argument("id");
        final Integer port = call.argument("port");
        final String address = call.argument("address");
        final String password = call.argument("password");
        final String encrypt = call.argument("encrypt");
        if (id == null || port == null || address == null || password == null || encrypt == null) {
            result.success(null);
            Logger.write(TAG + "updateShadowsocks", "Invalid arguments");
            return;
        }

        listener.onEstablishVpn(input -> {
            boolean prepared = (boolean) input;
            if (prepared) {
                try {
                    serviceMethod.updateServer(id, port, address, password, encrypt);
                } catch (Exception exception) {
                    Logger.write(TAG + "updateShadowsocks", exception);
                }
            }

            result.success(null);
            return null;
        });
    }

    private void updateSettings(MethodCall call, MethodChannel.Result result) {
        final Integer proxyPort = call.argument("proxyPort");
        final Integer localDnsPort = call.argument("localDnsPort");
        final String remoteDnsAddress = call.argument("remoteDnsAddress");

        if (proxyPort != null) {
            try {
                serviceMethod.setLocalDnsPort(proxyPort);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        if (localDnsPort != null) {
            try {
                serviceMethod.setLocalDnsPort(localDnsPort);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        if (remoteDnsAddress != null) {
            try {
                serviceMethod.setRemoteDnsAddress(remoteDnsAddress);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        // send result
        result.success(null);
    }

    // listener ------------------------------------------------------------------------------------
    public interface Listener {
        void onEstablishVpn(Function<Object, Void> callback);
    }
}
