package com.mtqmn.quranicare

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "QuraniCareMainActivity"
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, "HARAM MODE: Starting MainActivity configuration")
        
        try {
            super.configureFlutterEngine(flutterEngine)
            Log.d(TAG, "HARAM MODE: Super configuration successful")
        } catch (e: Exception) {
            Log.e(TAG, "HARAM MODE: Error in super configuration: ${e.message}", e)
        }
        
        // HARAM MODE: Safe plugin registration with detailed logging
        try {
            Log.d(TAG, "HARAM MODE: Starting plugin registration")
            GeneratedPluginRegistrant.registerWith(flutterEngine)
            Log.d(TAG, "HARAM MODE: Plugin registration completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "HARAM MODE: Plugin registration error: ${e.message}", e)
            // Continue without plugins - they'll work via platform channels
        }
        
        Log.d(TAG, "HARAM MODE: MainActivity configuration completed")
    }
    
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        Log.d(TAG, "HARAM MODE: MainActivity onCreate started")
        
        try {
            super.onCreate(savedInstanceState)
            Log.d(TAG, "HARAM MODE: MainActivity onCreate completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "HARAM MODE: MainActivity onCreate error: ${e.message}", e)
            throw e  // Re-throw to see the actual crash
        }
    }
}
