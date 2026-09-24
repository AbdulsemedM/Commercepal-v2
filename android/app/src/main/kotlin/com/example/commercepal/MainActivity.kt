package com.commercepal.commercepal

import android.annotation.SuppressLint
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getId" -> {
                    try {
                        result.success(androidId())
                    } catch (e: Exception) {
                        result.error(
                            "ERROR_GETTING_ID",
                            "Failed to get Android ID",
                            e.localizedMessage,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @SuppressLint("HardwareIds")
    private fun androidId(): String? =
        Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)

    companion object {
        private const val CHANNEL = "com.commercepal.commercepal/android_id"
    }
}
