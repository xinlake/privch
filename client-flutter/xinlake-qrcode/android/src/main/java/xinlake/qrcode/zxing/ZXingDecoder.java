package xinlake.qrcode.zxing;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

import java.io.FileInputStream;
import java.io.InputStream;


/**
 * @author Xinlake Liu
 * @version 2020.09
 */
public final class ZXingDecoder {
    private static final String Tag = "ZXingDecoder";

    @Nullable
    public static String decodeImage(@NonNull Context context, @NonNull Uri uri) {
        // try to decode QR code
        try {
            InputStream inputStream = context.getContentResolver().openInputStream(uri);
            if (inputStream == null) {
                throw new Exception("Invalid input");
            }

            String code = decodeImage(inputStream);
            inputStream.close();
            return code;
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        return null;
    }

    /**
     * @return The result or null
     */
    public static @Nullable
    String decodeImage(@NonNull String filePath) {
        // try to decode QR code
        try {
            FileInputStream inputStream = new FileInputStream(filePath);

            String code = decodeImage(inputStream);
            inputStream.close();
            return code;
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        return null;
    }

    private static String decodeImage(@NonNull InputStream inputStream) throws Exception {
        Bitmap bitmap = BitmapFactory.decodeStream(inputStream);

        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        int[] pixels = new int[width * height];

        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
        bitmap.recycle();

        RGBLuminanceSource source = new RGBLuminanceSource(width, height, pixels);
        BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));

        // get Result from decoder
        return new QRCodeReader().decode(binaryBitmap).getText();
    }
}
