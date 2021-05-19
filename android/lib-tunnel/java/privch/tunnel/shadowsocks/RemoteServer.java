package privch.tunnel.shadowsocks;

import android.util.Patterns;

import java.util.Objects;

/**
 * 2021-04
 */
public class RemoteServer {
    public final int port;
    public final String address;
    public final String password;
    public final String encrypt;

    public RemoteServer(int port, String address, String password, String encrypt) {
        this.port = port;
        this.address = address;
        this.password = password;
        this.encrypt = encrypt;
    }

    // TODO: Check if encryption is supported
    public boolean isValid() {
        return (port > 0) && (port < 65536)
            && (password != null) && (!password.isEmpty())
            && (encrypt != null) && (!encrypt.isEmpty())
            && (Patterns.IP_ADDRESS.matcher(address).matches()
            || Patterns.WEB_URL.matcher(address).matches());
    }

    @Override
    public boolean equals(Object object) {
        if (this == object) {
            return true;
        }

        if (object == null || getClass() != object.getClass()) {
            return false;
        }

        RemoteServer server = (RemoteServer) object;
        return port == server.port &&
            address.equals(server.address) &&
            password.equals(server.password) &&
            encrypt.equals(server.encrypt);
    }

    @Override
    public int hashCode() {
        return Objects.hash(port, address, password, encrypt);
    }
}
