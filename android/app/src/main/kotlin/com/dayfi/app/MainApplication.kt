package com.dayfi.app

import android.app.Application
import io.intercom.android.sdk.Intercom

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Native keys only — Flutter `main.dart` handles login and messenger UI.
        Intercom.initialize(this, "android_sdk-ca7182fe1675e2a978f6041b3c6d93e3672ca418", "ihv28wow")
        Intercom.client().setLauncherVisibility(Intercom.Visibility.GONE)
    }
}
