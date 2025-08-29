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
                "toggleAppLockTimer"->{
                   val packages = call.argument<String>("targetPackage")
val duration = call.argument<Long>("duration") 

val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
val editor = sharedPreferences.edit()


val existingSet = sharedPreferences.getStringSet("locked_apps", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
existingSet.add(packages ?: "")
editor.putStringSet("locked_apps", existingSet)


editor.putLong("lock_until_$packages", duration ?: 0L)
editor.apply()

if (packages != null && duration != null) {
    println("Locked package: $packages")
    println("Lock until (ms): $duration")
}

                }
                "argument"->{
                    val sharedPreferences = getSharedPreferences("LockScreenPrefs", Context.MODE_PRIVATE)
                    val editor = sharedPreferences.edit()
                    val lockedApps = sharedPreferences.getString("argument", null)
                    result.success(lockedApps)
                }
                "argument-delete"->{
                     val sharedPreferences = getSharedPreferences("LockScreenPrefs", Context.MODE_PRIVATE)
                    val editor = sharedPreferences.edit()
                    editor.remove("argument")
                    editor.apply()
                    result.success(true)
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
                "open-app"->{
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        val intent = packageManager.getLaunchIntentForPackage(packageName)
                        if (intent != null) {
                            startActivity(intent)
                            result.success(null)
                        } else {
                            result.error("APP_NOT_FOUND", "App not found: $packageName", null)
                        }
                    } else {
                        result.error("INVALID_PACKAGE", "Package name not provided", null)
                    }


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
            
            lockedApps.remove(targetPackage)
        } else {
            
            lockedApps.add(targetPackage)
        }

        
        editor.putStringSet("locked_apps", lockedApps)
        editor.apply()

        
        val intent = Intent(this, AppBlockerService::class.java)
        stopService(intent)
        startService(intent)

        println("  Locked Apps: $lockedApps")
        result.success( lockedApps.toList()) 
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
            
            val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()

            val lockedApps = sharedPreferences.getStringSet("locked_apps", emptySet())?.toMutableSet() ?: mutableSetOf()
            
            val currentTime = System.currentTimeMillis()
            val iterator = lockedApps.iterator()
            while (iterator.hasNext()) {
                val packageName = iterator.next()
                val lockUntil = sharedPreferences.getLong("lock_until_$packageName", 0L)
                if (lockUntil > 0L && currentTime > lockUntil) {
                    iterator.remove()
                    editor.remove("lock_until_$packageName")
                }
            }
            editor.putStringSet("locked_apps", lockedApps)
            editor.apply()  
           val newList =  sharedPreferences.getStringSet("locked_apps", emptySet())?.toMutableSet() ?: mutableSetOf()
            
            result.success(newList.toList())
        } catch (e: Exception) {
            println("Error retrieving lock status: ${e.message}");
            result.error("ERROR", "Failed to get lock status", e.localizedMessage)
        }
    }
}