package com.aiphotocoach.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var arHandler: ArPlatformHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        arHandler = ArPlatformHandler(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aiphotocoach.app/ar")
            .setMethodCallHandler(arHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.aiphotocoach.app/ar_events")
            .setStreamHandler(arHandler)
    }
}