package xinlake.armoury;

import android.content.ContentUris;
import android.content.Context;
import android.content.res.AssetManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.webkit.MimeTypeMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;


/**
 * @author Xinlake Liu, Opensource
 * @version 2021.11
 */
public final class XinFile {
    public enum AppDir {
        InternalCache, InternalFiles,
        ExternalCache, ExternalFiles,
    }

    // Utility class
    private XinFile() {
    }

    /**
     * No additional permissions are required for the calling app to read or write files under the returned path.
     *
     * @param fileName The name of the asset to open. This name can be hierarchical.
     * @return Return a path to file which may be read in common way.
     */
    @Nullable
    public static String cacheAssetFile(@NonNull Context context, @NonNull String fileName,
                                        AppDir targetDir, boolean overwrite) {
        File targetFile = getTargetFile(context, targetDir, fileName);
        return cacheAssetFile(context, fileName, targetFile, overwrite);
    }

    @Nullable
    public static String cacheAssetFile(@NonNull Context context, @NonNull String fileName,
                                        File targetFile, boolean overwrite) {

        final AssetManager assetManager = context.getAssets();
        InputStream inputStream = null;
        FileOutputStream fileOutputStream = null;
        String filePath = null;

        try {
            // check hash?
            if (targetFile.exists() && targetFile.length() > 0 && !overwrite) {
                return targetFile.getAbsolutePath();
            }

            // Create copy file in storage.
            inputStream = assetManager.open(fileName);
            fileOutputStream = new FileOutputStream(targetFile, false);
            copyStream(inputStream, fileOutputStream);

            // Return a path to file which may be read in common way.
            filePath = targetFile.getAbsolutePath();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        closeStream(inputStream);
        closeStream(fileOutputStream);
        return filePath;
    }

    @Nullable
    public static String cacheFromUri(@NonNull Context context, @NonNull Uri uri,
                                      AppDir targetDir, boolean overwrite) {

        String fileName = getFileName(context, uri);
        File targetFile = getTargetFile(context, targetDir, fileName);
        return cacheFromUri(context, uri, targetFile, overwrite);
    }

    @Nullable
    public static String cacheFromUri(@NonNull Context context, @NonNull Uri uri,
                                      File targetFile, boolean overwrite) {

        InputStream inputStream = null;
        FileOutputStream fileOutputStream = null;
        String filePath = null;

        try {
            // check hash?
            if (targetFile.exists() && targetFile.length() > 0 && !overwrite) {
                return targetFile.getAbsolutePath();
            }

            inputStream = context.getContentResolver().openInputStream(uri);
            fileOutputStream = new FileOutputStream(targetFile, false);
            copyStream(inputStream, fileOutputStream);

            filePath = targetFile.getAbsolutePath();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        closeStream(inputStream);
        closeStream(fileOutputStream);
        return filePath;
    }

    /**
     * @param textFile UTF-8 string lines
     * @return the string lines split by LF
     */
    @Nullable
    public static String[] readAssetText(@NonNull Context context, @NonNull String textFile) {
        final AssetManager assetManager = context.getAssets();
        InputStream inputStream = null;
        ByteArrayOutputStream byteArrayOutputStream = null;
        String[] lines = null;

        try {
            // Read data from assets.
            inputStream = assetManager.open(textFile);
            byteArrayOutputStream = new ByteArrayOutputStream();
            copyStream(inputStream, byteArrayOutputStream);

            String content = byteArrayOutputStream.toString(StandardCharsets.UTF_8.name());
            // String content = new String(data, StandardCharsets.UTF_8);
            lines = content.split("\n");
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        closeStream(inputStream);
        closeStream(byteArrayOutputStream);
        return lines;
    }

    public static long calculateFolderSize(File directory) {
        long length = 0;
        File[] files = directory.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isFile()) {
                    length += file.length();
                } else {
                    length += calculateFolderSize(file);
                }
            }
        }

        return length;
    }

    public static String getName(String filename) {
        if (filename == null) {
            return null;
        }

        int index = filename.lastIndexOf('/');
        if (index < 0) {
            return filename;
        }

        return filename.substring(index + 1);
    }

    /**
     * Gets the extension of a file name, like ".png" or ".jpg".
     *
     * @return Extension including the dot("."); "" if there is no extension;
     * null if uri was null.
     */
    public static String getExtension(String path) {
        if (path == null) {
            return null;
        }

        int dot = path.lastIndexOf(".");
        if (dot >= 0) {
            return path.substring(dot);
        } else {
            // No extension.
            return "";
        }
    }

    public static String getFileName(@NonNull Context context, Uri uri) {
        String mimeType = context.getContentResolver().getType(uri);
        String filename = null;

        if (mimeType == null) {
            String path = getPath(context, uri);
            if (path == null) {
                filename = getName(uri.toString());
            } else {
                File file = new File(path);
                filename = file.getName();
            }
        } else {
            Cursor returnCursor = context.getContentResolver().query(uri, null,
                null, null, null);
            if (returnCursor != null) {
                int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                returnCursor.moveToFirst();
                filename = returnCursor.getString(nameIndex);
                returnCursor.close();
            }
        }

        return filename;
    }

    /**
     * @return The MIME type for the given file.
     */
    public static String getMimeType(File file) {
        String extension = getExtension(file.getName());
        if (extension.length() > 0) {
            return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.substring(1));
        }

        return "application/octet-stream";
    }

    /**
     * @return The MIME type for the give String Uri.
     */
    public static String getMimeType(Context context, String url) {
        String type = context.getContentResolver().getType(Uri.parse(url));
        if (type == null) {
            type = "application/octet-stream";
        }

        return type;
    }

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context       The context.
     * @param uri           The Uri to query.
     * @param selection     (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public static String getDataColumn(Context context, Uri uri,
                                       String selection, String[] selectionArgs) {
        final String column = MediaStore.Files.FileColumns.DATA;
        final String[] projection = {column};

        Cursor cursor = null;
        String data = null;

        try {
            cursor = context.getContentResolver().query(uri,
                projection, selection, selectionArgs, null);
            if (cursor != null && cursor.moveToFirst()) {
                final int columnIndex = cursor.getColumnIndexOrThrow(column);
                data = cursor.getString(columnIndex);
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        if (cursor != null) {
            cursor.close();
        }
        return data;
    }

    /**
     * Get a file path from a Uri. This will get the the path for Storage Access
     * Framework Documents, as well as the _data field for the MediaStore and
     * other file-based ContentProviders. <br>
     * Callers should check whether the path is local before assuming it
     * represents a local file.
     *
     * @param context The context.
     * @param uri     The Uri to query.
     */
    @Nullable
    public static String getPath(final Context context, final Uri uri) {
        // DocumentProvider
        if (DocumentsContract.isDocumentUri(context, uri)) {
            // ExternalStorageProvider
            if ("com.android.externalstorage.documents".equals(uri.getAuthority())) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                } else if ("home".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/documents/" + split[1];
                }
            }
            // DownloadsProvider
            else if ("com.android.providers.downloads.documents".equals(uri.getAuthority())) {
                final String id = DocumentsContract.getDocumentId(uri);
                if (id == null) {
                    return null;
                } else if (id.startsWith("raw:")) {
                    return id.substring(4);
                }

                String[] contentUriPrefixesToTry = new String[]{
                    "content://downloads/downloads",
                    "content://downloads/documents",
                    "content://downloads/public_downloads",
                };
                for (String contentUriPrefix : contentUriPrefixesToTry) {
                    Uri contentUri;
                    try {
                        contentUri = ContentUris.withAppendedId(Uri.parse(contentUriPrefix), Long.parseLong(id));
                    } catch (Exception exception) {
                        exception.printStackTrace();
                        continue;
                    }

                    String path = getDataColumn(context, contentUri, null, null);
                    if (path != null) {
                        return path;
                    }
                }

                // path could not be retrieved using ContentResolver,
                // therefore copy file to accessible cache using streams
                return null;
            }
            // MediaProvider
            else if ("com.android.providers.media.documents".equals(uri.getAuthority())) {
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];

                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                } else if ("document".equals(type)) {
                    // FIXME
                    return null;
                }

                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{
                    split[1]
                };

                return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        }
        // MediaStore (and general)
        else if ("content".equalsIgnoreCase(uri.getScheme())) {
            return getDataColumn(context, uri, null, null);
        }
        // File
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }

        return null;
    }

    @Nullable
    public static File generateFileName(@Nullable String name, File directory) {
        if (name == null) {
            return null;
        }

        File file = new File(directory, name);
        if (file.exists()) {
            String fileName = name;
            String extension = "";
            int dotIndex = name.lastIndexOf('.');
            if (dotIndex > 0) {
                fileName = name.substring(0, dotIndex);
                extension = name.substring(dotIndex);
            }

            int index = 0;
            while (file.exists()) {
                index++;
                name = fileName + '-' + index + extension;
                file = new File(directory, name);
            }
        }

        return file;
    }

    // internal ------------------------------------------------------------------------------------
    @NonNull
    private static File getTargetFile(Context context, @NonNull AppDir targetDir, String fileName) {
        switch (targetDir) {
            case InternalCache:
                return new File(context.getCacheDir(), fileName);
            case InternalFiles:
                return new File(context.getFilesDir(), fileName);
            case ExternalCache:
                return new File(context.getExternalCacheDir(), fileName);
            default: // ExternalFile:
                return new File(context.getExternalFilesDir(null), fileName);
        }
    }

    private static void copyStream(InputStream input, OutputStream output) throws IOException {
        byte[] buffer = new byte[1024];
        int read;
        while ((read = input.read(buffer)) != -1) {
            output.write(buffer, 0, read);
        }
    }

    private static void closeStream(InputStream stream) {
        if (stream != null) {
            try {
                stream.close();
            } catch (IOException exception) {
                exception.printStackTrace();
            }
        }
    }
    private static void closeStream(OutputStream stream) {
        if (stream != null) {
            try {
                stream.close();
            } catch (IOException exception) {
                exception.printStackTrace();
            }
        }
    }
}
