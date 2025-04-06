package com.example.control

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.content.Intent
import android.content.Context
class AppBlockerService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) {
            Log.w(TAG, "Received null event in onAccessibilityEvent")
            return
        }

        try {
            val packageName = event.packageName?.toString() ?: "unknown"

            // Retrieve blocked apps from SharedPreferences
           val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        val lockedApps = sharedPreferences.getStringSet("locked_apps", emptySet())?.toMutableSet() ?: mutableSetOf()

            Log.d(TAG, "Blocked Apps: $lockedApps")
            

            Log.d(TAG, "Event received for package: $packageName")

            // Check if the opened app is in the blocked list
            if (packageName in lockedApps) {
                Log.i(TAG, "Blocked app detected: $packageName")
                performGlobalAction(GLOBAL_ACTION_BACK) // Example action to close the app

                // Push the blocked app package name to your app
                val intent = Intent("com.example.control.BLOCKED_APP_EVENT")
                intent.putExtra("blockedPackageName", packageName)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) // Ensure the intent starts a new task
                applicationContext.sendBroadcast(intent)
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
        private const val TAG = "AppBlockerService"
    }
}
