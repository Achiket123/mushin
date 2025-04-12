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

    if (packageName == applicationContext.packageName) {
        Log.d(TAG, "Ignoring event from own app")
        return
    }

    val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
    val lockedApps = sharedPreferences.getStringSet("locked_apps", emptySet()) ?: emptySet()

    if (packageName in lockedApps) {
        val lockUntilKey = "lock_until_$packageName"
        val lockUntilTime = sharedPreferences.getLong(lockUntilKey, -1L)
        val currentTime = System.currentTimeMillis()

        if (lockUntilTime == -1L || currentTime < lockUntilTime) {
            // Block app if:
            // A) No time set (always lock), OR
            // B) Lock time is in future

            Log.i(TAG, "Blocking app: $packageName (lockUntil=${if (lockUntilTime == -1L) "not set" else lockUntilTime})")

            val intent = Intent(applicationContext, LockScreenActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("package", packageName)
            }
            applicationContext.startActivity(intent)
        } else {
            // Optional: Clean up expired lock
            Log.i(TAG, "Lock expired for $packageName, removing from locked list")
            val newSet = lockedApps.toMutableSet()
            newSet.remove(packageName)
            sharedPreferences.edit().apply {
                putStringSet("locked_apps", newSet)
                remove(lockUntilKey) // remove lock time key
                apply()
            }
        }
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
