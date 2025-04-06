package com.example.control


import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.content.Intent

class LockScreenActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_lock_screen)

        val unlockButton: Button = findViewById(R.id.unlockButton)
        val lockText: TextView = findViewById(R.id.lockText)

        lockText.text = "This app is locked."

        unlockButton.setOnClickListener {
            // Go to home screen instead of just finishing
            val homeIntent = Intent(Intent.ACTION_MAIN)
            homeIntent.addCategory(Intent.CATEGORY_HOME)
            homeIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(homeIntent)
            
            finish() // Close LockScreenActivity
        }
    }
    
    // Prevent back button from bypassing the lock
    override fun onBackPressed() {
        val homeIntent = Intent(Intent.ACTION_MAIN)
        homeIntent.addCategory(Intent.CATEGORY_HOME)
        homeIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(homeIntent)
        
        finish()
    }
}