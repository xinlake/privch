package privch.tunnel;

import android.content.Context;

import androidx.test.platform.app.InstrumentationRegistry;

import junit.framework.TestCase;

public class PrivChTunnelTest extends TestCase {

    public void testCreate() {
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        PrivChTunnel.create(appContext);
        return;
    }
}
