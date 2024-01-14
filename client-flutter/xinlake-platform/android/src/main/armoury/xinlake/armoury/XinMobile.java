package xinlake.armoury;

import androidx.annotation.NonNull;

import java.util.Locale;

public class XinMobile {
    // Utility class
    private XinMobile() {
    }


    public static String connectWords(@NonNull String delimiter, String... words) {
        final StringBuilder stringBuilder = new StringBuilder();
        for (String word : words) {
            if (word != null && !word.isEmpty()) {
                stringBuilder.append(word).append(delimiter);
            }
        }

        return stringBuilder.substring(0, stringBuilder.length() - delimiter.length());
    }

    public static String generateIp() {
        return String.format(Locale.US, "%d.%d.%d.%d",
            (int) (255 * Math.random()),
            (int) (255 * Math.random()),
            (int) (255 * Math.random()),
            (int) (255 * Math.random()));
    }
}
