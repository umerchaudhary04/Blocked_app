package com.example.blocked_app

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor

class BlockedVpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null

    // Phase 2: Static status for checking
    companion object {
        var isRunning = false
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Phase 2: Handle STOP action
        if (intent?.action == "STOP_VPN") {
            stopVpn()
            return START_NOT_STICKY
        }

        if (vpnInterface != null) return START_STICKY // Already running

        val builder = Builder()
        builder.addAddress("10.0.0.2", 32)
        builder.addRoute("0.0.0.0", 0)
        // Ensure standard DNS for this phase, update to Cloudflare Family for protection
        builder.addDnsServer("1.1.1.3")

        try {
            vpnInterface = builder.setSession("Blocked VPN").establish()
            isRunning = true // Phase 2: Update status
        } catch (e: Exception) {
            e.printStackTrace()
            isRunning = false // Phase 2: Update status on failure
        }
        
        return START_STICKY
    }

    private fun stopVpn() {
        vpnInterface?.close()
        vpnInterface = null
        isRunning = false // Phase 2: Update status
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }
}