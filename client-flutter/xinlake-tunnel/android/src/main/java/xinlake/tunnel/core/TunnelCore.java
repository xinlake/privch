package xinlake.tunnel.core;

import android.app.ActivityManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;

import androidx.annotation.NonNull;

import java.io.File;

/**
 * Construct and initialized in the tunnel process
 *
 * @author Xinlake Liu
 * @version 2021-11
 */
public final class TunnelCore {
    public static final String ACTION_EVENT_BROADCAST = "xinlake.tunnel.broadcast";
    public static final int STATE_CONNECTING = 1;
    public static final int STATE_CONNECTED = 2;
    public static final int STATE_STOPPING = 3;
    public static final int STATE_STOPPED = 4;

    public final Context appContext;
    public final ActivityManager activityManager;
    public final ConnectivityManager connectivityManager;

    public final PendingIntent configureIntent;
    public final File noBackupFilesDir;
    public final String nativeLibraryDir;

    public int socksPort;
    public int dnsLocalPort;
    public String dnsRemoteAddress;

    // single instance -----------------------------------------------------------------------------
    private static TunnelCore tunnelCore;

    private TunnelCore(Context appContext) {
        activityManager = appContext.getSystemService(ActivityManager.class);
        connectivityManager = appContext.getSystemService(ConnectivityManager.class);

        configureIntent = PendingIntent.getActivity(
            appContext, 0,
            new Intent("xinlake.tunnel.ConfigVpn")
                .setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT),
            PendingIntent.FLAG_IMMUTABLE);
        noBackupFilesDir = appContext.getNoBackupFilesDir();
        nativeLibraryDir = appContext.getApplicationInfo().nativeLibraryDir;

        // settings
        this.appContext = appContext;
        this.socksPort = 7080;
        this.dnsLocalPort = 7081;
        this.dnsRemoteAddress = "8.8.8.8";
    }

    public static void init(@NonNull Context appContext) {
        tunnelCore = new TunnelCore(appContext);
    }

    public static TunnelCore instance() {
        return tunnelCore;
    }

    // private address -----------------------------------------------------------------------------
    public static final String[] BYPASS_PRIVATE_ROUTE = {
        "1.0.0.0/8",
        "2.0.0.0/7",
        "4.0.0.0/6",
        "8.0.0.0/7",
        "11.0.0.0/8",
        "12.0.0.0/6",
        "16.0.0.0/4",
        "32.0.0.0/3",
        "64.0.0.0/3",
        "96.0.0.0/6",
        "100.0.0.0/10",
        "100.128.0.0/9",
        "101.0.0.0/8",
        "102.0.0.0/7",
        "104.0.0.0/5",
        "112.0.0.0/10",
        "112.64.0.0/11",
        "112.96.0.0/12",
        "112.112.0.0/13",
        "112.120.0.0/14",
        "112.124.0.0/19",
        "112.124.32.0/21",
        "112.124.40.0/22",
        "112.124.44.0/23",
        "112.124.46.0/24",
        "112.124.48.0/20",
        "112.124.64.0/18",
        "112.124.128.0/17",
        "112.125.0.0/16",
        "112.126.0.0/15",
        "112.128.0.0/9",
        "113.0.0.0/8",
        "114.0.0.0/10",
        "114.64.0.0/11",
        "114.96.0.0/12",
        "114.112.0.0/15",
        "114.114.0.0/18",
        "114.114.64.0/19",
        "114.114.96.0/20",
        "114.114.112.0/23",
        "114.114.115.0/24",
        "114.114.116.0/22",
        "114.114.120.0/21",
        "114.114.128.0/17",
        "114.115.0.0/16",
        "114.116.0.0/14",
        "114.120.0.0/13",
        "114.128.0.0/9",
        "115.0.0.0/8",
        "116.0.0.0/6",
        "120.0.0.0/6",
        "124.0.0.0/7",
        "126.0.0.0/8",
        "128.0.0.0/3",
        "160.0.0.0/5",
        "168.0.0.0/8",
        "169.0.0.0/9",
        "169.128.0.0/10",
        "169.192.0.0/11",
        "169.224.0.0/12",
        "169.240.0.0/13",
        "169.248.0.0/14",
        "169.252.0.0/15",
        "169.255.0.0/16",
        "170.0.0.0/7",
        "172.0.0.0/12",
        "172.32.0.0/11",
        "172.64.0.0/10",
        "172.128.0.0/9",
        "173.0.0.0/8",
        "174.0.0.0/7",
        "176.0.0.0/4",
        "192.0.0.8/29",
        "192.0.0.16/28",
        "192.0.0.32/27",
        "192.0.0.64/26",
        "192.0.0.128/25",
        "192.0.1.0/24",
        "192.0.3.0/24",
        "192.0.4.0/22",
        "192.0.8.0/21",
        "192.0.16.0/20",
        "192.0.32.0/19",
        "192.0.64.0/18",
        "192.0.128.0/17",
        "192.1.0.0/16",
        "192.2.0.0/15",
        "192.4.0.0/14",
        "192.8.0.0/13",
        "192.16.0.0/12",
        "192.32.0.0/11",
        "192.64.0.0/12",
        "192.80.0.0/13",
        "192.88.0.0/18",
        "192.88.64.0/19",
        "192.88.96.0/23",
        "192.88.98.0/24",
        "192.88.100.0/22",
        "192.88.104.0/21",
        "192.88.112.0/20",
        "192.88.128.0/17",
        "192.89.0.0/16",
        "192.90.0.0/15",
        "192.92.0.0/14",
        "192.96.0.0/11",
        "192.128.0.0/11",
        "192.160.0.0/13",
        "192.169.0.0/16",
        "192.170.0.0/15",
        "192.172.0.0/14",
        "192.176.0.0/12",
        "192.192.0.0/10",
        "193.0.0.0/8",
        "194.0.0.0/7",
        "196.0.0.0/7",
        "198.0.0.0/12",
        "198.16.0.0/15",
        "198.20.0.0/14",
        "198.24.0.0/13",
        "198.32.0.0/12",
        "198.48.0.0/15",
        "198.50.0.0/16",
        "198.51.0.0/18",
        "198.51.64.0/19",
        "198.51.96.0/22",
        "198.51.101.0/24",
        "198.51.102.0/23",
        "198.51.104.0/21",
        "198.51.112.0/20",
        "198.51.128.0/17",
        "198.52.0.0/14",
        "198.56.0.0/13",
        "198.64.0.0/10",
        "198.128.0.0/9",
        "199.0.0.0/8",
        "200.0.0.0/7",
        "202.0.0.0/8",
        "203.0.0.0/18",
        "203.0.64.0/19",
        "203.0.96.0/20",
        "203.0.112.0/24",
        "203.0.114.0/23",
        "203.0.116.0/22",
        "203.0.120.0/21",
        "203.0.128.0/17",
        "203.1.0.0/16",
        "203.2.0.0/15",
        "203.4.0.0/14",
        "203.8.0.0/13",
        "203.16.0.0/12",
        "203.32.0.0/11",
        "203.64.0.0/10",
        "203.128.0.0/9",
        "204.0.0.0/6",
        "208.0.0.0/4",
    };
}
