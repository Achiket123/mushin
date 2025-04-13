package com.example.control

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.CountDownTimer
import android.view.View
import android.widget.Button
import android.widget.TextView
import android.content.SharedPreferences

class LockScreenActivity : Activity() {

    private lateinit var unlockButton: Button
    private lateinit var lockText: TextView
    private lateinit var timerText: TextView
    private lateinit var countDownTimer: CountDownTimer

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_lock_screen)

        unlockButton = findViewById(R.id.unlockButton)
        lockText = findViewById(R.id.lockText)
        timerText = findViewById(R.id.timerText)

        val blockedPackage = intent.getStringExtra("package") ?: "Unknown"
        val sharedPreferences = getSharedPreferences("AppLockPrefs", Context.MODE_PRIVATE)

        lockText.text = "This app is locked."

        // Handle manual unlock
        unlockButton.setOnClickListener {
            val sharedPreferencesforAppOpener = getSharedPreferences("LockScreenPrefs", Context.MODE_PRIVATE)
            sharedPreferencesforAppOpener.edit().putString("argument", blockedPackage).apply()

            val mainIntent = Intent(this, MainActivity::class.java)
            mainIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(mainIntent)
            finish()
        }

        // Get the unlock timestamp in millis
        val unlockAt = sharedPreferences.getLong("lock_until_$blockedPackage", 0L)
        val currentTime = System.currentTimeMillis()
        val timeRemaining = unlockAt - currentTime

        if (timeRemaining > 0) {
            // Start countdown
            startCountdown(timeRemaining, blockedPackage, sharedPreferences)
        } else {
            // No timer active or already expired
            timerText.visibility = View.GONE
            unlockButton.isEnabled = true
        }
    }

    private fun startCountdown(durationMillis: Long, blockedPackage: String, sharedPreferences: SharedPreferences) {
        timerText.visibility = View.VISIBLE
        unlockButton.isEnabled = false

        countDownTimer = object : CountDownTimer(durationMillis, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                val minutes = (millisUntilFinished / 1000) / 60
                val seconds = (millisUntilFinished / 1000) % 60
                timerText.text = "Time remaining: %02d:%02d".format(minutes, seconds)
            }

            override fun onFinish() {
                timerText.text = "Unlocked!"
                val editor = sharedPreferences.edit()
                // Automatically open the app
                editor.putString("argument", blockedPackage).apply()
                 val lockedApps = sharedPreferences.getStringSet("locked_apps", emptySet())?.toMutableSet() ?: mutableSetOf()

        val isLocked = lockedApps.contains(blockedPackage)

        if (isLocked) {
            
            lockedApps.remove(blockedPackage)
        } else {
            
            lockedApps.add(blockedPackage)
        }

        
        editor.putStringSet("locked_apps", lockedApps)
        editor.apply()
        val launchIntent = packageManager.getLaunchIntentForPackage(blockedPackage)
        if (launchIntent != null) {
            startActivity(launchIntent)
        } else {
            val mainIntent = Intent(this@LockScreenActivity, MainActivity::class.java)
            mainIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(mainIntent)
        }
        finish()
            }
        }
        countDownTimer.start()
    }

    override fun onBackPressed() {
        val homeIntent = Intent(Intent.ACTION_MAIN)
        homeIntent.addCategory(Intent.CATEGORY_HOME)
        homeIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(homeIntent)
        finish()
    }

    override fun onDestroy() {
        if (this::countDownTimer.isInitialized) {
            countDownTimer.cancel()
        }
        super.onDestroy()
    }
}
