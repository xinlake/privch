package armoury.ready.runner;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.view.View;
import android.widget.Toast;

import androidx.activity.ComponentActivity;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;

import xinlake.armoury.XinFile;

public class UriPathRunner implements View.OnClickListener {
    private final ActivityResultLauncher<String> requestPermissionLauncher;
    private final ActivityResultLauncher<String[]> openDocumentLauncher;

    @SuppressLint("SetTextI18n")
    public UriPathRunner(ComponentActivity activity) {
        openDocumentLauncher = activity.registerForActivityResult(
            new ActivityResultContracts.OpenDocument(),
            uri -> {
                if (uri != null) {
                    StringBuilder stringBuilder = new StringBuilder();
                    stringBuilder.append("URI").append("\n")
                        .append(uri).append("\n\n");
                    String filePath = XinFile.getPath(activity, uri);
                    if (filePath == null) {
                        filePath = XinFile.cacheFromUri(activity, uri, XinFile.AppDir.ExternalFiles, true);
                        stringBuilder.append("CACHED ");
                    }
                    stringBuilder.append("PATH").append("\n")
                        .append(filePath);

                    new AlertDialog.Builder(activity)
                        .setTitle("Uri Path")
                        .setMessage(stringBuilder.toString())
                        .setPositiveButton("OK", null)
                        .show();
                }
            });

        requestPermissionLauncher = activity.registerForActivityResult(
            new ActivityResultContracts.RequestPermission(),
            granted -> {
                if (granted) {
                    openDocumentLauncher.launch(new String[]{"image/*"});
                } else {
                    Toast.makeText(activity,
                        "Permission Denied",
                        Toast.LENGTH_LONG).show();
                }
            });
    }

    @Override
    public void onClick(View view) {
        requestPermissionLauncher.launch(Manifest.permission.READ_EXTERNAL_STORAGE);
    }
}
