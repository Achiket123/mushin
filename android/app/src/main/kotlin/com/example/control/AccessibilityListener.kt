package com.example.control

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AccessibilityListener : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) {
            Log.w(TAG, "Received null event in onAccessibilityEvent")
            return
        }

        try {
            val eventType = event.eventType
            val packageName = event.packageName ?: "unknown"
            val className = event.className ?: "unknown"

            Log.d(TAG, "Event received:")
            Log.d(TAG, "  Type: $eventType")
            Log.d(TAG, "  Package: $packageName")
            Log.d(TAG, "  Class: $className")

            // Optional: Inspect node info
            val nodeInfo: AccessibilityNodeInfo? = event.source
            nodeInfo?.let {
                Log.d(TAG, "  Node text: ${it.text}")
                Log.d(TAG, "  Node class: ${it.className}")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error processing accessibility event: ${e.message}", e)
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "Accessibility Service interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.i(TAG, "Accessibility Service connected successfully")
    }

    companion object {
        private const val TAG = "AccessibilityListener"
    }
}