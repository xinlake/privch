package privch.flutter.widgets;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;

import armoury.vision.ZXingEncoder;
import armoury.vision.ZXingFormat;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * TODO. There are some issues, the image turns to black when the code is changed.
 * Image view. Example:
 * AndroidView(
 * viewType: "image-view",
 * creationParamsCodec: const StandardMessageCodec(),
 * creationParams: <String, dynamic>{
 * "code": widget.ssEdit.encodeBase64(),
 * "size": (size * 4).toInt(),
 * },),
 */
public class ImageFactory extends PlatformViewFactory {
    public static final String typeId = "image-view";

    // Specific the codec used to decode the args parameter of {@link #create}.
    public ImageFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    // Creates a new Android view to be embedded in the Flutter hierarchy.
    @Override @NonNull
    @SuppressWarnings("unchecked")
    public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
        final HashMap<String, Object> creationParams = (HashMap<String, Object>) args;
        return new ImageWidget(context, viewId, creationParams);
    }

    private static class ImageWidget implements PlatformView {
        private final ImageView imageView;
        private Bitmap bitmap;

        private ImageWidget(@NonNull Context context, int viewId,
                            HashMap<String, Object> creationParams) {
            String code = (String) creationParams.get("code");
            Integer size = (Integer) creationParams.get("size");

            bitmap = ZXingEncoder.encodeText(code, ZXingFormat.QR_CODE, size);

            imageView = new ImageView(context);
            imageView.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            imageView.setImageBitmap(bitmap);
        }

        // Returns the Android view to be embedded in the Flutter hierarchy.
        @Override @NonNull
        public View getView() {
            imageView.invalidate();
            return imageView;
        }

        // Dispose this platform view.
        @Override
        public void dispose() {
            bitmap.recycle();
            bitmap = null;
        }
    }
}
