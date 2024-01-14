package xinlake.qrcode.zxing;

import com.google.zxing.BarcodeFormat;

public class ZXingFormat {
    public static final int AZTEC = 100;
    public static final int CODABAR = 101;
    public static final int CODE_39 = 102;
    public static final int CODE_93 = 103;
    public static final int CODE_128 = 104;
    public static final int DATA_MATRIX = 105;
    public static final int EAN_8 = 106;
    public static final int EAN_13 = 107;
    public static final int ITF = 108;
    public static final int MAXICODE = 109;
    public static final int PDF_417 = 110;
    public static final int QR_CODE = 111;
    public static final int RSS_14 = 112;
    public static final int RSS_EXPANDED = 113;
    public static final int UPC_A = 114;
    public static final int UPC_E = 115;
    public static final int UPC_EAN_EXTENSION = 116;

    protected static BarcodeFormat getFormat(int format) {
        switch (format) {
            case AZTEC:
                return BarcodeFormat.AZTEC;
            case CODABAR:
                return BarcodeFormat.CODABAR;
            case CODE_39:
                return BarcodeFormat.CODE_39;
            case CODE_93:
                return BarcodeFormat.CODE_93;
            case CODE_128:
                return BarcodeFormat.CODE_128;
            case DATA_MATRIX:
                return BarcodeFormat.DATA_MATRIX;
            case EAN_8:
                return BarcodeFormat.EAN_8;
            case EAN_13:
                return BarcodeFormat.EAN_13;
            case ITF:
                return BarcodeFormat.ITF;
            case MAXICODE:
                return BarcodeFormat.MAXICODE;
            case PDF_417:
                return BarcodeFormat.PDF_417;
            case QR_CODE:
                return BarcodeFormat.QR_CODE;
            case RSS_14:
                return BarcodeFormat.RSS_14;
            case RSS_EXPANDED:
                return BarcodeFormat.RSS_EXPANDED;
            case UPC_A:
                return BarcodeFormat.UPC_A;
            case UPC_E:
                return BarcodeFormat.UPC_E;
            case UPC_EAN_EXTENSION:
                return BarcodeFormat.UPC_EAN_EXTENSION;
        }

        // default
        return BarcodeFormat.QR_CODE;
    }
}
