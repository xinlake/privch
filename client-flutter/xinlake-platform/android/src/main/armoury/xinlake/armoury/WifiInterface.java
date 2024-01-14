package xinlake.armoury;

import androidx.annotation.NonNull;

import java.net.Inet4Address;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.LinkedList;
import java.util.List;


/**
 * @author Xinlake Liu
 * @version 2020.12
 */
public class WifiInterface {
    public final String name;
    public final List<String> ip4List;
    public final List<String> ip6List;

    public WifiInterface(String name, List<String> ip4List, List<String> ip6List) {
        this.name = name;
        this.ip4List = ip4List;
        this.ip6List = ip6List;
    }

    @NonNull
    public static List<WifiInterface> getIpAddress() {
        List<WifiInterface> interfaceList = new LinkedList<>();

        try {
            Enumeration<NetworkInterface> interfaceEnumeration = NetworkInterface.getNetworkInterfaces();
            while (interfaceEnumeration.hasMoreElements()) {
                NetworkInterface networkInterface = interfaceEnumeration.nextElement();
                if (networkInterface.isUp() &&
                    !networkInterface.isVirtual() && !networkInterface.isLoopback() &&
                    networkInterface.getName().toLowerCase().contains("wlan")) {

                    List<String> ip4Addresses = new ArrayList<>();
                    List<String> ip6Addresses = new ArrayList<>();

                    Enumeration<InetAddress> addressEnumeration = networkInterface.getInetAddresses();
                    while (addressEnumeration.hasMoreElements()) {
                        InetAddress inetAddress = addressEnumeration.nextElement();
                        if (inetAddress.isLoopbackAddress() ||
                            ((inetAddress instanceof Inet6Address) && inetAddress.isLinkLocalAddress())) {
                            continue;
                        }

                        if (inetAddress instanceof Inet4Address) {
                            ip4Addresses.add(inetAddress.getHostAddress());
                        } else if (inetAddress instanceof Inet6Address) {
                            ip6Addresses.add(inetAddress.getHostAddress());
                        }
                    }

                    if (ip4Addresses.size() > 0 || ip6Addresses.size() > 0) {
                        interfaceList.add(new WifiInterface(
                            networkInterface.getName(), ip4Addresses, ip6Addresses));
                    }
                }
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        return interfaceList;
    }
}
