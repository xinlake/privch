package xinlake.tunnel.aidl;

// ITunnelMethod.aidl
// int, long, boolean, float, double, String

interface ITunnelMethod {
    int getState();

    void setSocksPort(in int port);
    void setDnsLocalPort(in int port);
    void setDnsRemoteAddress(in String address);

    boolean startService(in int port, in String address, in String password, in String encrypt);
    void stopService();
    boolean toggleService();
}
