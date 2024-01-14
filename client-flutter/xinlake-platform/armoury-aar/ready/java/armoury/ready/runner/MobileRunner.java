package armoury.ready.runner;

import android.app.AlertDialog;
import android.view.View;

import androidx.activity.ComponentActivity;

import xinlake.armoury.XinMobile;

public class MobileRunner implements View.OnClickListener {
    private final ComponentActivity activity;

    public MobileRunner(ComponentActivity activity) {
        this.activity = activity;
    }

    @Override
    public void onClick(View view) {
        new AlertDialog.Builder(activity)
            .setMessage("setNavigationBar")
            .setPositiveButton("LIGHT", (dialogInterface, i) -> {
                // set to light mode
                XinMobile.setNavigationBar(activity, 0xFFFFFFFF, null, 300);
            })
            .setNegativeButton("DARK", (dialogInterface, i) -> {
                // set to dark mode
                XinMobile.setNavigationBar(activity, 0xFF000000, null, 300);
            })
            .show();
    }
}
