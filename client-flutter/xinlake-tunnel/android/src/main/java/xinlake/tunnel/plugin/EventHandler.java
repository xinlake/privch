package xinlake.tunnel.plugin;

import androidx.annotation.MainThread;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

public class EventHandler implements EventChannel.StreamHandler {
    private EventChannel.EventSink eventSink;

    @MainThread
    public void notifyStateChanged(int state) {
        if (eventSink != null) {
            HashMap<String, Object> events = new HashMap<>();
            events.put("state", state);

            eventSink.success(events);
        }
    }

    /*
     * Handles a request to set up an event stream.
     *
     * <p>Any uncaught exception thrown by this method will be caught by the channel implementation
     * and logged. An error result message will be sent back to Flutter.
     * @param arguments stream configuration arguments, possibly null.
     * @param events    an EventSink for emitting events to the Flutter receiver.
     */
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    /*
     * Handles a request to tear down the most recently created event stream.
     *
     * <p>Any uncaught exception thrown by this method will be caught by the channel implementation
     * and logged. An error result message will be sent back to Flutter.
     *
     * <p>The channel implementation may call this method with null arguments to separate a pair of
     * two consecutive set up requests. Such request pairs may occur during Flutter hot restart. Any
     * uncaught exception thrown in this situation will be logged without notifying Flutter.
     * @param arguments stream configuration arguments, possibly null.
     */
    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }
}
