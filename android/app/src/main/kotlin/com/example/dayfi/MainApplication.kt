package com.example.dayfi

import io.flutter.app.FlutterApplication
import io.intercom.android.sdk.Intercom

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        
        // Initialize Intercom
        Intercom.initialize(this, "android_sdk-ca7182fe1675e2a978f6041b3c6d93e3672ca418", "ihv28wow")
        Intercom.client().loginUnidentifiedUser()
        Intercom.client().setLauncherVisibility(Intercom.Visibility.VISIBLE)
    }
}
