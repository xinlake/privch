package xinlake.tunnel.core.shadowsocks;

import xinlake.tunnel.aidl.ITunnelMethod;
import xinlake.tunnel.core.TunnelCore;

/**
 * 2021-11
 */
public class ServiceBinder extends ITunnelMethod.Stub {
    final private SSService service;

    public ServiceBinder(SSService service) {
        this.service = service;
    }

    @Override
    public int getState() {
        return service.getState();
    }

    @Override
    public void setSocksPort(int port) {
        TunnelCore.instance().socksPort = port;
    }

    @Override
    public void setDnsLocalPort(int port) {
        TunnelCore.instance().dnsLocalPort = port;
    }

    @Override
    public void setDnsRemoteAddress(String address) {
        TunnelCore.instance().dnsRemoteAddress = address;
    }

    @Override
    public boolean startService(int port, String address, String password, String encrypt) {
        return service.startService(port, address, password, encrypt);
    }

    @Override
    public void stopService() {
        service.stopRunner();
    }

    @Override
    public boolean toggleService() {
        return service.toggleService();
    }
}
