package com.example.control

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockerService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) {
            Log.w(TAG, "Received null event in onAccessibilityEvent")
            return
        }

        try {
            val packageName = event.packageName?.toString() ?: return

            // ✅ Skip your own app to avoid infinite loop and crash
            if (packageName == applicationContext.packageName) {
                Log.d(TAG, "Ignoring event from own app")
                return
            }

            // ✅ Get locked apps list from SharedPreferences
            val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
            val lockedApps = sharedPreferences.getStringSet("locked_apps", emptySet()) ?: emptySet()

            Log.d(TAG, "Accessibility Event for package: $packageName")
            Log.d(TAG, "Locked Apps List: $lockedApps")

            // ✅ Check if current app is locked
            if (packageName in lockedApps) {
                Log.i(TAG, "Blocked app detected: $packageName")

                // ✅ Launch your own app with info
                val intent = Intent(applicationContext, LockScreenActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                 
                }
                intent.putExtra("package", packageName)
                applicationContext.startActivity(intent)
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
