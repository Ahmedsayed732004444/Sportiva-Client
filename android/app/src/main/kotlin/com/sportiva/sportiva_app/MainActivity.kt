package com.sportiva.sportiva_app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // The app reads the Google Maps key from the manifest (it is put there at build time from local.properties),
    // so the key is set in one place only.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sportiva/config").setMethodCallHandler { call, result ->
            if (call.method == "mapsKey") {
                val info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                result.success(info.metaData?.getString("com.google.android.geo.API_KEY") ?: "")
            } else {
                result.notImplemented()
            }
        }
    }
}
