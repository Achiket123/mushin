package com.example.control

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.provider.Settings
import android.util.Log
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class AppMonitorService : Service() {
    private val handler = Handler()
    private val interval: Long = 2000 // Check every 2 seconds
    private lateinit var sharedPreferences: SharedPreferences
    private val gson = Gson()

    override fun onCreate() {
        super.onCreate()
        sharedPreferences = getSharedPreferences("AppLockPrefs", MODE_PRIVATE)
        createNotificationChannel()
        startForeground(1, createNotification())
        handler.post(checkForegroundApp)
    }

    private val checkForegroundApp = object : Runnable {
        override fun run() {
            val foregroundApp = getForegroundApp()
            Log.d("AppMonitor", "Foreground App: $foregroundApp")
            
            // Skip if it's our own app
            if (foregroundApp != null && foregroundApp != packageName) {
                val lockedApps = getLockedApps()
                if (lockedApps.contains(foregroundApp)) {
                    // Launch LockScreenActivity to prevent access
                    Log.d("AppMonitor", "🚫 Blocking $foregroundApp")

                    // Launch lock screen instead of home screen
                    val lockIntent = Intent(this@AppMonitorService, LockScreenActivity::class.java)
                    lockIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(lockIntent)
                }
            }

            handler.postDelayed(this, interval)
        }
    }

    private fun getForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val usageEvents = usageStatsManager.queryEvents(time - 5000, time)
        val event = UsageEvents.Event()
        var foregroundApp: String? = null

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                foregroundApp = event.packageName
            }
        }

        return foregroundApp
    }

    private fun getLockedApps(): List<String> {
        val json = sharedPreferences.getString("locked_apps", "[]")
        val type = object : TypeToken<List<String>>() {}.type
        return gson.fromJson(json, type) ?: emptyList()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "app_monitor",
                "App Monitor Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return Notification.Builder(this, "app_monitor")
            .setContentTitle("App Monitor Running")
            .setContentText("Detecting foreground apps...")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(checkForegroundApp)
    }
}