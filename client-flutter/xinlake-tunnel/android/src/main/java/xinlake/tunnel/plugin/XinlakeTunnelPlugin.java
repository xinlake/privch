package xinlake.tunnel.plugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

/**
 * XinlakeTunnelPlugin
 * 2021-11
 */
public class XinlakeTunnelPlugin implements FlutterPlugin, ActivityAware {
    private final MethodHandler methodHandler = new MethodHandler();
    private final EventHandler eventHandler = new EventHandler();

    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;

    // (Second) ActivityAware ----------------------------------------------------------------------
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        methodHandler.attachedToActivity(binding, eventHandler);
    }

    @Override
    public void onDetachedFromActivity() {
        methodHandler.detachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        methodHandler.attachedToActivity(binding, eventHandler);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        methodHandler.detachedFromActivity();
    }

    // (First) FlutterPlugin -----------------------------------------------------------------------
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),
            "xinlake_tunnel_event");
        eventChannel.setStreamHandler(eventHandler);

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
            "xinlake_tunnel_method");
        methodChannel.setMethodCallHandler(methodHandler);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }
}
