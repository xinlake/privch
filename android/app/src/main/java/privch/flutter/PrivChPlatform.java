package privch.flutter;

import android.app.Activity;

import androidx.annotation.NonNull;

import privch.flutter.channel.DataMethod;
import privch.flutter.channel.PlatformEvent;
import privch.flutter.channel.VpnMethod;
import privch.flutter.channel.XinMethod;

public final class PrivChPlatform {
    public final PlatformEvent platformEvent;
    public final XinMethod xinMethod;
    public final DataMethod dataMethod;
    public final VpnMethod vpnMethod;

    // single instance -----------------------------------------------------------------------------
    public static PrivChPlatform getInstance() {
        return platform;
    }

    public static void create(@NonNull Activity activity,
                              @NonNull DataMethod.Listener dataListener,
                              @NonNull VpnMethod.Listener vpnListener) {
        platform = new PrivChPlatform(activity, dataListener, vpnListener);
    }

    public static void dispose() {
        platform.disposeAll();
        platform = null;
    }

    /**
     * single instance.
     */
    private PrivChPlatform(Activity activity,
                           DataMethod.Listener dataListener,
                           VpnMethod.Listener vpnListener) {
        platformEvent = new PlatformEvent(activity);
        xinMethod = new XinMethod(activity);
        dataMethod = new DataMethod(activity, dataListener);
        vpnMethod = new VpnMethod(activity, platformEvent, vpnListener);
    }

    private void disposeAll() {
        vpnMethod.dispose();
    }

    private static PrivChPlatform platform;
}
