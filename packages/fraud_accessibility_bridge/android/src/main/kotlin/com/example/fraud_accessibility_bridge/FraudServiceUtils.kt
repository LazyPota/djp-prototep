package com.example.fraud_accessibility_bridge

import android.content.Context
import android.provider.Settings

internal object FraudServiceUtils {
    private const val SERVICE_CLASS = "com.example.fraud_accessibility_bridge.FraudAccessibilityService"

    fun isServiceEnabled(context: Context): Boolean {
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val expected = "${context.packageName}/$SERVICE_CLASS"
        return enabledServices.split(":").any { it.equals(expected, ignoreCase = true) }
    }
}
