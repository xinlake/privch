package xinlake.armoury;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.LinkProperties;
import android.net.Network;
import android.net.TrafficStats;

import androidx.annotation.NonNull;

import java.net.InetAddress;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class XinNet {
    // Utility class
    private XinNet() {
    }

    @NonNull
    public static List<String> getDefaultDNS(@NonNull Context context) {
        final List<String> listDns = new ArrayList<>();
        final ConnectivityManager cm = (ConnectivityManager) context.getSystemService(
            Context.CONNECTIVITY_SERVICE);

        Network activeNetwork = cm.getActiveNetwork();
        if (activeNetwork != null) {
            LinkProperties linkProperties = cm.getLinkProperties(activeNetwork);
            if (linkProperties != null) {
                List<InetAddress> dnsList = linkProperties.getDnsServers();
                for (InetAddress dns : dnsList) {
                    String hostAddress = dns.getHostAddress();
                    if (hostAddress != null) {
                        listDns.add(hostAddress.split("%")[0]);
                    }
                }
            }
        }

        return listDns;
    }

    /**
     * @return "rx": rx bytes, "tx": tx bytes.
     */
    @NonNull
    public static HashMap<String, Long> getSelfTrafficBytes(@NonNull Context context) {
        int uid = context.getApplicationInfo().uid;
        long uidTotalTx = TrafficStats.getUidTxBytes(uid);
        long uidTotalRx = TrafficStats.getUidRxBytes(uid);

        HashMap<String, Long> hashMap = new HashMap<>();
        hashMap.put("rx", uidTotalRx);
        hashMap.put("tx", uidTotalTx);
        return hashMap;
    }
}
