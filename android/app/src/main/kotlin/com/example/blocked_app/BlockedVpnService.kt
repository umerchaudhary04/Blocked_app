package com.example.blocked_app

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class BlockedVpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null

    // This allows MainActivity to check our status
    companion object {
        var isRunning = false
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "STOP_VPN") {
            stopVpn()
            return START_NOT_STICKY
        }

        if (vpnInterface != null) return START_STICKY // Already running

        val builder = Builder()
        builder.addAddress("10.0.0.2", 32)
        builder.addRoute("0.0.0.0", 0)
        builder.addDnsServer("1.1.1.3")

        try {
            vpnInterface = builder.setSession("Blocked VPN").establish()
            isRunning = true
        } catch (e: Exception) {
            e.printStackTrace()
            isRunning = false
        }
        
        return START_STICKY
    }

    private fun stopVpn() {
        vpnInterface?.close()
        vpnInterface = null
        isRunning = false
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }
}