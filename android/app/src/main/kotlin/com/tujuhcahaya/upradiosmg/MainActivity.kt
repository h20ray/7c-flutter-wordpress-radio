package com.tujuhcahaya.upradiosmg

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "audio_focus"
    private lateinit var audioFocusHandler: AudioFocusHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioFocusHandler = AudioFocusHandler(this)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        audioFocusHandler.setMethodChannel(channel)
        channel.setMethodCallHandler(audioFocusHandler)
    }
}
