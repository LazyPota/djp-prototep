package com.example.fraud_accessibility_bridge

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class FraudAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val eventPackage = event?.packageName?.toString()
        if (!eventPackage.isNullOrBlank()) {
            lastObservedPackage = eventPackage
            return
        }

        val rootPackage = rootInActiveWindow?.packageName?.toString()
        if (!rootPackage.isNullOrBlank()) {
            lastObservedPackage = rootPackage
        }
    }

    override fun onInterrupt() {
        // No-op
    }

    override fun onDestroy() {
        if (instance === this) {
            instance = null
        }
        super.onDestroy()
    }

    companion object {
        @Volatile
        var instance: FraudAccessibilityService? = null
            private set

        @Volatile
        var lastObservedPackage: String? = null
            private set
    }
}
