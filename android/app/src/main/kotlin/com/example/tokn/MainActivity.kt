package com.example.tokn

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "tokn.upi/payment"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchUpi") {
                val uriString = call.arguments as? String
                if (uriString == null) {
                    result.error("INVALID_ARGS", "URI String is null", null)
                    return@setMethodCallHandler
                }

                val uri = Uri.parse(uriString)
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = uri
                
                val chooser = Intent.createChooser(intent, "Pay with...")
                
                pendingResult = result
                try {
                    startActivityForResult(chooser, 1001)
                } catch (e: Exception) {
                    result.error("APP_NOT_FOUND", "No UPI App found", null)
                    pendingResult = null
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 1001) {
            if (data != null) {
                // Typical UPI intent response comes in 'response' Extra string
                val response = data.getStringExtra("response") ?: "STATUS=UNKNOWN"
                pendingResult?.success(response)
            } else {
                pendingResult?.success("STATUS=FAILURE")
            }
            pendingResult = null
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}
