package privch.flutter.channel;

import android.app.Activity;
import android.net.TrafficStats;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

/**
 * 2021-04-26
 */
public class PlatformEvent implements EventChannel.StreamHandler {
    public static final String CHANNEL_NAME = "privch-event";

    private final Activity activity;
    private EventChannel.EventSink eventSink;

    public PlatformEvent(@NonNull Activity activity) {
        this.activity = activity;
    }

    @MainThread
    public void vpnMessage(String message) {
        if (eventSink != null) {
            HashMap<String, Object> events = new HashMap<>();
            events.put("vpnMessage", message);

            eventSink.success(events);
        }
    }

    @MainThread
    public void vpnServerChanged(int serverId) {
        if (eventSink != null) {
            HashMap<String, Object> events = new HashMap<>();
            events.put("vpnServerId", serverId);

            eventSink.success(events);
        }
    }

    @MainThread
    public void vpnStateChanged(boolean isVpnRunning) {
        if (eventSink != null) {
            HashMap<String, Object> events = new HashMap<>();
            events.put("vpnRunning", isVpnRunning);

            eventSink.success(events);
        }
    }

    @MainThread
    public void platformConfigChanged(boolean isNightMode) {
        if (eventSink != null) {
            HashMap<String, Object> events = new HashMap<>();
            events.put("platformNightMode", isNightMode);

            eventSink.success(events);
        }
    }

    /**
     * TODO: Move traffic bytes updating to the flutter side
     * Handles a request to set up an event stream.
     * @param arguments stream configuration arguments, possibly null.
     * @param events    an EventSink for emitting events to the Flutter receiver.
     */
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;

        new Thread(() -> {
            final int uid = activity.getApplicationInfo().uid;

            while (eventSink != null) {
                try {
                    final long selfTx = TrafficStats.getUidTxBytes(uid);
                    final long selfRx = TrafficStats.getUidRxBytes(uid);

                    for (int i = 0; i < 10; ++i) {
                        Thread.sleep(100);

                        if (eventSink == null) {
                            return;
                        }
                    }

                    final long selfTx2 = TrafficStats.getUidTxBytes(uid);
                    final long selfRx2 = TrafficStats.getUidRxBytes(uid);

                    // send result
                    activity.runOnUiThread(() -> {
                        HashMap<String, Long> map = new HashMap<>();
                        map.put("selfTx", selfTx2 - selfTx);
                        map.put("selfRx", selfRx2 - selfRx);
                        eventSink.success(map);
                    });
                } catch (Exception ignored) {
                    break;
                }
            }
        }, "EventHandler-TrafficStats").start();
    }

    /**
     * Handles a request to tear down the most recently created event stream.
     * @param arguments stream configuration arguments, possibly null.
     */
    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }
}
