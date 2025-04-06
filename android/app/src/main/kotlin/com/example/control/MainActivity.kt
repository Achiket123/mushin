package com.example.control

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val CHANNEL = "lock_app_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        if (!isAccessibilityEnabled()) {
            requestAccessibilityPermission()
        }
        
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "toggleAppLock" -> {
                    val targetPackage = call.argument<String>("targetPackage")
                    if (targetPackage != null) {
                        toggleAppLock(targetPackage, result)
                    } else {
                        result.error("INVALID_PACKAGE", "Target package not provided", null)
                    }
                }
                "getLockStatus" -> {
                    
                    
                        getLockStatus( result)
                    
                }
                "openAccessibilitySettings"->{
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(null)
                }
                "isAccessibilityEnabled" -> {
                    val enabled = isAccessibilityEnabled()
                    result.success(enabled)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun toggleAppLock(targetPackage: String, result: MethodChannel.Result) {
    try {
        val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        val lockedApps = sharedPreferences.getStringSet("locked_apps", emptySet())?.toMutableSet() ?: mutableSetOf()

        val isLocked = lockedApps.contains(targetPackage)

        if (isLocked) {
            // Unlock the app (remove from locked list)
            lockedApps.remove(targetPackage)
        } else {
            // Lock the app (add to locked list)
            lockedApps.add(targetPackage)
        }

        // Save updated locked apps
        editor.putStringSet("locked_apps", lockedApps)
        editor.apply()

        // Restart AppBlockerService to apply changes
        val intent = Intent(this, AppBlockerService::class.java)
        stopService(intent)
        startService(intent)

        println("  Locked Apps: $lockedApps")
        result.success(!isLocked)
    } catch (e: Exception) {
        result.error("TOGGLE_FAILED", "Failed to toggle lock", e.message)
    }
}


    private fun isAccessibilityEnabled(): Boolean {
        val enabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED, 0
        ) == 1
        
        if (!enabled) return false
        
        // Check if our specific service is enabled
        val serviceString = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        
        return serviceString.contains("${packageName}/${packageName}.AppBlockerService")
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
    
    private fun getLockStatus(  result: MethodChannel.Result) {
        try {
            // Retrieve locked apps from SharedPreferences
            val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
            val lockedAppsJson = sharedPreferences.getString("locked_apps", "[]")
            val gson = com.google.gson.Gson()
            val typeToken = object : com.google.gson.reflect.TypeToken<List<String>>() {}.type
            val lockedApps: List<String> = gson.fromJson(lockedAppsJson, typeToken) ?: emptyList()
 
            println("Error retrieving lock status: ${lockedApps}");

            // Return the result to Flutter
            result.success(lockedApps)
        } catch (e: Exception) {
            println("Error retrieving lock status: ${e.message}");
            result.error("ERROR", "Failed to get lock status", e.localizedMessage)
        }
    }
}