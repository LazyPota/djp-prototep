package com.example.fraud_accessibility_bridge

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FraudAccessibilityBridgePlugin */
class FraudAccessibilityBridgePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fraud_accessibility_bridge")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getCurrentForegroundApp" -> {
                val service = FraudAccessibilityService.instance
                val fromRoot = service?.rootInActiveWindow?.packageName?.toString()
                val fromEvents = FraudAccessibilityService.lastObservedPackage
                result.success(fromRoot ?: fromEvents)
            }

            "isAccessibilityServiceEnabled" -> {
                val context = applicationContext
                if (context == null) {
                    result.success(false)
                    return
                }
                result.success(FraudServiceUtils.isServiceEnabled(context))
            }

            "openAccessibilitySettings" -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("NO_ACTIVITY", "No foreground Activity available to open settings.", null)
                    return
                }
                try {
                    currentActivity.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                } catch (e: Exception) {
                    result.error("OPEN_SETTINGS_FAILED", e.message, null)
                }
            }

            "checkAndCopyProductLink" -> {
                val timeoutMs = (call.argument<Number>("timeoutMs")?.toLong() ?: 6000L).coerceIn(1000L, 30000L)
                val context = applicationContext
                if (context == null) {
                    result.success(mapOf("status" to "error", "message" to "No application context"))
                    return
                }
                val service = FraudAccessibilityService.instance
                if (service == null) {
                    result.success(
                        mapOf(
                            "status" to "error",
                            "message" to "Accessibility service not running. Enable it in Settings > Accessibility."
                        )
                    )
                    return
                }

                FraudAutomationController.runShareCopyFlow(
                    service = service,
                    appContext = context,
                    timeoutMs = timeoutMs
                ) { payload ->
                    result.success(payload)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
