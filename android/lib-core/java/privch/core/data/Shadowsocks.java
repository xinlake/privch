package privch.core.data;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import armoury.common.Confidential;
import armoury.common.XinText;

/**
 * Field modification should be synchronized to the Dart side
 * <p>
 * 2021-04
 */
@Entity
public class Shadowsocks {
    @PrimaryKey
    public int id;

    public String encrypt;
    public String password;
    public String address;
    public int port;

    // remarks
    public String name;
    public String modified;

    // info
    public String geoLocation;
    public int responseTime;
    public int order;

    /**
     * deserialize from map to shadowsocks
     */
    public Shadowsocks() {
        modified = XinText.formatCurrentTime("yyyy-MM-dd HH:mm:ss");
    }

    public Shadowsocks(@NonNull String encrypt, @NonNull String password,
                       @NonNull String address, int port, String tag) {
        this();

        this.encrypt = encrypt;
        this.password = password;
        this.address = address;
        this.port = port;

        if (tag != null && !tag.isEmpty()) {
            name = tag;
        } else {
            name = address + " - " + port;
        }

        // id is related to address and port
        id = hashCode();
    }

    @Override
    public boolean equals(Object object) {
        if (this == object) {
            return true;
        }

        if (object == null || getClass() != object.getClass()) {
            return false;
        }

        Shadowsocks ss = (Shadowsocks) object;
        return port == ss.port && address.equals(ss.address);
    }

    @Override
    public int hashCode() {
        return Objects.hash(port, address);
    }

    // utilities -----------------------------------------------------------------------------------
    public static List<Shadowsocks> random(int count) {
        List<Shadowsocks> ssList = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            int hostPort = (int) (65535 * Math.random());
            String hostAddress = XinText.generateIp();
            Shadowsocks shadowsocks = new Shadowsocks("salsa20", "password",
                hostAddress, hostPort, null);
            ssList.add(shadowsocks);
        }

        return ssList;
    }

    /**
     * Create a Shadowsocks object from map,
     * if the id field is 0 it will be set to its hash code
     */
    @Nullable
    public static Shadowsocks fromMap(HashMap<String, Object> map) {
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            final Shadowsocks ss = objectMapper.convertValue(map, Shadowsocks.class);
            if (ss.id == 0) {
                ss.id = ss.hashCode();
            }

            return ss;
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        return null;
    }

    /**
     * Create a list of Shadowsocks objects from a map list,
     * if the id field is 0 it will be set to its hash code
     */
    @NonNull
    public static List<Shadowsocks> fromMap(@NonNull List<HashMap<String, Object>> mapList) {
        ObjectMapper objectMapper = new ObjectMapper();
        List<Shadowsocks> ssList = new ArrayList<>();

        for (HashMap<String, Object> map : mapList) {
            try {
                final Shadowsocks ss = objectMapper.convertValue(map, Shadowsocks.class);
                if (ss.id == 0) {
                    ss.id = ss.hashCode();
                }

                ssList.add(ss);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        return ssList;
    }

    @SuppressWarnings("unchecked")
    public static HashMap<String, Object> toMap(@NonNull Shadowsocks ss) {
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.convertValue(ss, HashMap.class);
    }

    @NonNull
    @SuppressWarnings("unchecked")
    public static List<HashMap<String, Object>> toMap(@NonNull List<Shadowsocks> ssList) {
        ObjectMapper objectMapper = new ObjectMapper();
        List<HashMap<String, Object>> mapList = new ArrayList<>();

        for (Shadowsocks ss : ssList) {
            HashMap<String, Object> map = objectMapper.convertValue(ss, HashMap.class);
            mapList.add(map);
        }

        return mapList;
    }

    @Nullable
    public static Shadowsocks fromQrCode(String qrCode) {
        if (qrCode == null || !qrCode.startsWith("ss://")) {
            return null;
        }

        // remove prefix
        String ssInfo = qrCode.substring(5);

        Shadowsocks shadowsocks;
        if (ssInfo.contains("@")) {
            // shadowsocks-android v4 generated format
            shadowsocks = parseV4(ssInfo);
        } else {
            shadowsocks = parse(ssInfo);
        }

        return shadowsocks;
    }

    @Nullable
    private static Shadowsocks parse(String ssInfo) {
        String[] ssBase64Tag = ssInfo.split("#");
        String ssUrl = Confidential.base64DecodeX(ssBase64Tag[0]);
        if (ssUrl == null) {
            return null;
        }

        Matcher match = UrlPattern.matcher(ssUrl);
        if (match.matches()) {
            try {
                String encrypt = match.group(1);
                String password = match.group(2);
                String address = match.group(3);
                int port = Integer.parseInt(Objects.requireNonNull(match.group(4)));

                String tag = (ssBase64Tag.length == 2) ? ssBase64Tag[1] : null;
                if (encrypt != null && password != null && address != null) {
                    return new Shadowsocks(encrypt, password, address, port, tag);
                }
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        return null;
    }

    /**
     * format: {BASE64@ADDRESS:PORT}, base64: {ENCRYPT:PASSWORD}
     * This format is generated by shadowsocks-android v4
     */
    @Nullable
    private static Shadowsocks parseV4(String ssInfo) {
        // check ss code
        String ssEncryptBase64, ssAddressInfo;
        try {
            String[] info = ssInfo.split("@");
            ssEncryptBase64 = info[0];
            ssAddressInfo = info[1];
        } catch (Exception ignored) {
            return null;
        }

        // decode encrypt info
        String ssEncryptInfo = Confidential.base64DecodeX(ssEncryptBase64);
        if (ssEncryptInfo == null) {
            return null;
        }

        String[] ssEncryptPassword = ssEncryptInfo.split(":");
        if (ssEncryptPassword.length != 2) {
            return null;
        }

        String encrypt = ssEncryptPassword[0];
        String password = ssEncryptPassword[1];

        // parse address info
        String[] ssAddressPort = ssAddressInfo.split(":");
        if (ssAddressPort.length != 2) {
            return null;
        }

        String address = ssAddressPort[0];
        try {
            int port = Integer.parseInt(ssAddressPort[1]);
            return new Shadowsocks(encrypt, password, address, port, null);
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        return null;
    }

    /*
    shadowsocks 1.9.0
     */
    public static final Pattern UrlPattern = Pattern.compile("^(.+?):(.*)@(.+?):(\\d+?)$");
    public static final String[] Ciphers = new String[]{
        "plain",
        "none",
        "table",
        "rc4-md5",
        "aes-128-ctr", "aes-192-ctr", "aes-256-ctr",
        "aes-128-cfb", "aes-128-cfb1", "aes-128-cfb8", "aes-128-cfb128",
        "aes-192-cfb", "aes-192-cfb1", "aes-192-cfb8", "aes-192-cfb128",
        "aes-256-cfb", "aes-256-cfb1", "aes-256-cfb8", "aes-256-cfb128",
        "aes-128-ofb", "aes-192-ofb", "aes-256-ofb",
        "camellia-128-ctr", "camellia-192-ctr", "camellia-256-ctr",
        "camellia-128-cfb", "camellia-128-cfb1", "camellia-128-cfb8", "camellia-128-cfb128",
        "camellia-192-cfb", "camellia-192-cfb1", "camellia-192-cfb8", "camellia-192-cfb128",
        "camellia-256-cfb", "camellia-256-cfb1", "camellia-256-cfb8", "camellia-256-cfb128",
        "camellia-128-ofb", "camellia-192-ofb", "camellia-256-ofb",
        "rc4",
        "aes-128-gcm", "aes-256-gcm",
        "chacha20-ietf", "chacha20-ietf-poly1305",
    };
}
