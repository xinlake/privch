package privch.core;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * 2021-04
 */
public class PrivChPreference {
    public static final String prefName = "privch-preference";

    public static final String keyCurrentServerId = "current-server-id";
    public static final String keyThemeSetting = "theme-setting";

    // tunnel preferences
    public static final String keyProxyPort = "proxy-port";
    public static final String keyLocalDnsPort = "local-dns-port";
    public static final String keyRemoteDnsAddress = "remote-dns-address";

    public static final int defProxyPort = 1080;
    public static final int defLocalDnsPort = 5450;
    public static final String defRemoteDnsAddress = "8.8.8.8";

    public static SharedPreferences getPreferences(Context appContext) {
        return appContext.getSharedPreferences(prefName, Context.MODE_PRIVATE);
    }
}
