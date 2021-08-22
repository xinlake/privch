package privch.tunnel;

import android.app.ActivityManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;

import androidx.annotation.NonNull;

import java.io.File;

import privch.core.PrivChPreference;

/**
 * 2021-04
 */
public final class PrivChTunnel {
    public final Context appContext;
    public final ActivityManager activityManager;
    public final ConnectivityManager connectivityManager;

    public final PendingIntent configureIntent;
    public final File noBackupFilesDir;
    public final String nativeLibraryDir;

    public int portProxy;
    public int portLocalDns;
    public String remoteDnsAddress;

    // single instance
    private static PrivChTunnel tunnel;

    private PrivChTunnel(Context appContext) {
        this.appContext = appContext;
        activityManager = appContext.getSystemService(ActivityManager.class);
        connectivityManager = appContext.getSystemService(ConnectivityManager.class);

        configureIntent = PendingIntent.getActivity(appContext, 0,
            new Intent("xinlake.privch.flutter.ConfigVpn")
                .setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT),
            PendingIntent.FLAG_IMMUTABLE);
        noBackupFilesDir = appContext.getNoBackupFilesDir();
        nativeLibraryDir = appContext.getApplicationInfo().nativeLibraryDir;

        /*
         * access preference in this current process
         */
        SharedPreferences preferences = appContext.getSharedPreferences(PrivChPreference.prefName, Context.MODE_PRIVATE);
        portProxy = preferences.getInt(PrivChPreference.keyProxyPort, PrivChPreference.defProxyPort);
        portLocalDns = preferences.getInt(PrivChPreference.keyLocalDnsPort, PrivChPreference.defLocalDnsPort);
        remoteDnsAddress = preferences.getString(PrivChPreference.keyRemoteDnsAddress, PrivChPreference.defRemoteDnsAddress);
    }

    public static void create(@NonNull Context appContext) {
        tunnel = new PrivChTunnel(appContext);
    }

    public static PrivChTunnel getInstance() {
        return tunnel;
    }
}
