package com.architect.enterprise.method_channel_example

import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val SECURITY_CHANNEL = "com.architect.enterprise/security"
    private val HARDWARE_EVENTS_CHANNEL = "com.architect.enterprise/hardware_events"

    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())
    private var eventRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. MethodChannel for Request/Response Operations
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSecurityStatus" -> {
                        val isRooted = checkRootMethod()
                        val securityData = mapOf(
                            "isCompromised" to isRooted,
                            "osVersion" to "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})",
                            "securityPatchLevel" to (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) Build.VERSION.SECURITY_PATCH else "N/A"),
                            "hasSecureHardware" to true
                        )
                        result.success(securityData)
                    }
                    "verifyBiometrics" -> {
                        val reason = call.argument<String>("promptReason") ?: "Authentication"
                        // In production: BiometricPrompt.authenticate()
                        // Here we simulate successful biometric authentication
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // 2. EventChannel for Continuous Native Streams
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HARDWARE_EVENTS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    // Simulate native hardware broadcast every 5 seconds
                    var count = 0
                    eventRunnable = object : Runnable {
                        override fun run() {
                            eventSink?.success("Hardware pulse #$count (Battery: Optimal)")
                            count++
                            handler.postDelayed(this, 5000)
                        }
                    }
                    handler.post(eventRunnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    eventRunnable?.let { handler.removeCallbacks(it) }
                    eventSink = null
                }
            })
    }

    private fun checkRootMethod(): Boolean {
        val buildTags = Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) return true

        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su"
        )
        return paths.any { File(it).exists() }
    }
}
