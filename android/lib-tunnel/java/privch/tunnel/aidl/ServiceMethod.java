package privch.tunnel.aidl;

import android.os.RemoteException;

import privch.tunnel.IServiceEvent;
import privch.tunnel.IServiceMethod;
import privch.tunnel.PrivChTunnel;
import privch.tunnel.shadowsocks.SSService;

/**
 * 2021-04
 */
public class ServiceMethod extends IServiceMethod.Stub {
    final private SSService service;

    public ServiceMethod(SSService service) {
        this.service = service;
    }

    @Override
    public void setListener(IServiceEvent listener) throws RemoteException {
        service.setListener(listener);
    }

    @Override
    public void setProxyPort(int port) throws RemoteException {
        PrivChTunnel.getInstance().portProxy = port;
    }

    @Override
    public void setLocalDnsPort(int port) throws RemoteException {
        PrivChTunnel.getInstance().portLocalDns = port;
    }

    @Override
    public void setRemoteDnsAddress(String address) throws RemoteException {
        PrivChTunnel.getInstance().remoteDnsAddress = address;
    }

    @Override
    public boolean updateServer(int serverId, int port, String address, String password, String encrypt) throws RemoteException {
        return service.updateServer(serverId, port, address, password, encrypt);
    }

    @Override
    public void stopService() throws RemoteException {
        service.stopRunner(true);
    }
}
