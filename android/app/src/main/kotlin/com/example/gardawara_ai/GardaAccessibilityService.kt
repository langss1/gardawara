package com.example.gardawara_ai

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.Toast
import android.util.Log
import android.content.Context
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class GardaAccessibilityService : AccessibilityService() {

    private val blacklist = listOf(
        "judi", "slot gacor", "toto", "situs gacor", "bandar judi", "taruhan bola", "judi online",
        "888slot", "slot88", "maxwin", "rtp", "pragmatic", "deposit pulsa", "gacor hari ini", 
        "casino", "hoki", "zeus", "login slot", "daftar slot", "bet"
    )

    override fun onServiceConnected() {
        super.onServiceConnected()
        createNotificationChannel()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.packageName != null && event.packageName == packageName) return

        val rootNode = rootInActiveWindow ?: return
        if (checkForRestrictedContent(rootNode)) {
             // 1. Aggressive Blocking
             performGlobalAction(GLOBAL_ACTION_BACK)
             performGlobalAction(GLOBAL_ACTION_HOME) // Force Home
             
             // 2. Increment Counter
             incrementBlockedCount()

             // 3. Show Notification
             showBlockingNotification()

             // 4. Toast
             Toast.makeText(applicationContext, "GardaWara: ⛔ JUDI TERDETEKSI! Akses Diblokir.", Toast.LENGTH_LONG).show()
        }
    }

    private fun checkForRestrictedContent(node: AccessibilityNodeInfo): Boolean {
        if (node.text != null) {
            val content = node.text.toString().lowercase()
            for (keyword in blacklist) {
                if (content.contains(keyword)) {
                    Log.d("GardaService", "Blocked: $keyword")
                    return true
                }
            }
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                if (checkForRestrictedContent(child)) {
                    child.recycle()
                    return true
                }
                child.recycle()
            }
        }
        return false
    }

    private fun incrementBlockedCount() {
        // Use "FlutterSharedPreferences" to key "flutter.blocked_count" so Flutter app can read it directly via SharedPrefs plugin
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val currentCount = prefs.getLong("flutter.blocked_count", 0L)
        prefs.edit().putLong("flutter.blocked_count", currentCount + 1).apply()
    }

    private fun showBlockingNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notification = NotificationCompat.Builder(this, "GARDA_CHANNEL")
            .setContentTitle("🛡️ GardaWara Beraksi")
            .setContentText("Situs judi berhasil diblokir. Tetap aman!")
            .setSmallIcon(android.R.drawable.ic_secure) 
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()
        
        notificationManager.notify(1001, notification)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "GARDA_CHANNEL",
                "GardaWara Protection",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "Notifications for blocked content"
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onInterrupt() {}
}
