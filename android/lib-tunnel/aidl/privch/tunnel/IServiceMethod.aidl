package privch.tunnel;
import privch.tunnel.IServiceEvent;

// IServiceMethod.aidl
// int anInt, long aLong, boolean aBoolean, float aFloat, double aDouble, String aString

interface IServiceMethod {
    void setListener(in IServiceEvent listener);

    void setProxyPort(in int port);
    void setLocalDnsPort(in int port);
    void setRemoteDnsAddress(in String address);

    boolean updateServer(in int id, in int port, in String address, in String password, in String encrypt);
    void stopService();
}
