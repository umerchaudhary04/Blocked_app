package com.example.blocked_app

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.blocked.app/native"
    private var pendingResult: MethodChannel.Result? = null
    private val VPN_REQUEST_CODE = 24

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startProtection" -> {
                    pendingResult = result
                    startVpn()
                }
                "stopProtection" -> {
                    val intent = Intent(this, BlockedVpnService::class.java)
                    intent.action = "STOP_VPN"
                    startService(intent)
                    result.success("DISCONNECTED")
                }
                "getStatus" -> {
                    result.success(if (BlockedVpnService.isRunning) "CONNECTED" else "DISCONNECTED")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startVpn() {
        val vpnIntent = VpnService.prepare(this)
        if (vpnIntent != null) {
            // Android requires the user to grant permission
            startActivityForResult(vpnIntent, VPN_REQUEST_CODE)
        } else {
            // Permission was already granted previously
            startVpnService()
            pendingResult?.success("CONNECTED")
            pendingResult = null
        }
    }

    // This catches the user's choice on the permission pop-up!
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == VPN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                startVpnService()
                pendingResult?.success("CONNECTED")
            } else {
                pendingResult?.success("PERMISSION_DENIED")
            }
            pendingResult = null
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun startVpnService() {
        val intent = Intent(this, BlockedVpnService::class.java)
        intent.action = "START_VPN"
        startService(intent)
    }
}