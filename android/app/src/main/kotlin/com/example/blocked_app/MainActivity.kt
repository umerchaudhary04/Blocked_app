package com.example.blocked_app

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.blocked.app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startProtection" -> {
                    startVpnAndScreenCapture()
                    result.success(true)
                }
                "stopProtection" -> {
                    // TODO: Stop background services
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startVpnAndScreenCapture() {
        val vpnIntent = VpnService.prepare(this)
        if (vpnIntent != null) {
            startActivityForResult(vpnIntent, 0)
        } else {
            val intent = Intent(this, BlockedVpnService::class.java)
            startService(intent)
        }
        // MediaProjection initialization will go here
    }
}