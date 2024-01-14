package armoury.ready;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.widget.TextView;

import androidx.activity.ComponentActivity;

import armoury.ready.runner.MobileRunner;
import armoury.ready.runner.NetworkRunner;
import armoury.ready.runner.UriPathRunner;
import xinlake.armoury.Logger;
import xinlake.armoury.ready.R;

public class ActivityMain extends ComponentActivity {
    private static final String Tag = ActivityMain.class.getSimpleName();

    @Override
    @SuppressLint("SetTextI18n")
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Logger logger = new Logger(getFilesDir().getAbsolutePath());
        logger.write(Tag, "hello");

        setContentView(R.layout.activity_main);
        ((TextView) findViewById(R.id.main_text_version)).setText("version "
            + xinlake.platform.BuildConfig.versionName);

        // utilities
        findViewById(R.id.main_mobile).setOnClickListener(new MobileRunner(this));
        findViewById(R.id.main_uri_path).setOnClickListener(new UriPathRunner(this));
        findViewById(R.id.main_network_address).setOnClickListener(new NetworkRunner(this));
    }
}
