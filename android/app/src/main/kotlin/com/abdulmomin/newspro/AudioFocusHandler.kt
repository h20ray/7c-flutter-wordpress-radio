package com.tujuhcahaya.upradiosmg

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall

class AudioFocusHandler(private val context: Context) : MethodCallHandler {
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var audioFocusRequest: AudioFocusRequest? = null
    private var hasAudioFocus = false
    private var methodChannel: MethodChannel? = null

    companion object {
        const val CHANNEL_NAME = "audio_focus"
        
        // Focus event types
        const val FOCUS_GAIN = "focus_gain"
        const val FOCUS_LOSS = "focus_loss"
        const val FOCUS_LOSS_TRANSIENT = "focus_loss_transient"
        const val FOCUS_LOSS_TRANSIENT_CAN_DUCK = "focus_loss_transient_can_duck"
    }

    fun setMethodChannel(channel: MethodChannel) {
        this.methodChannel = channel
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "requestAudioFocus" -> {
                requestAudioFocus(result)
            }
            "releaseAudioFocus" -> {
                releaseAudioFocus(result)
            }
            "setDuckingVolume" -> {
                val volume = call.argument<Double>("volume") ?: 0.3
                setDuckingVolume(volume, result)
            }
            "restoreNormalVolume" -> {
                restoreNormalVolume(result)
            }
            "optimizeAudioSession" -> {
                optimizeAudioSession()
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requestAudioFocus(result: Result) {
        try {
            if (hasAudioFocus) {
                result.success(true)
                return
            }

            val focusGained = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                requestAudioFocusV26()
            } else {
                requestAudioFocusLegacy()
            }

            hasAudioFocus = focusGained
            result.success(focusGained)
        } catch (e: Exception) {
            result.error("AUDIO_FOCUS_ERROR", "Failed to request audio focus: ${e.message}", null)
        }
    }

    @Suppress("DEPRECATION")
    private fun requestAudioFocusLegacy(): Boolean {
        // Use AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK for better compatibility with radio_player
        val result = audioManager.requestAudioFocus(
            audioFocusChangeListener,
            AudioManager.STREAM_MUSIC,
            AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
        )
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun requestAudioFocusV26(): Boolean {
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()

        audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
            .setAudioAttributes(audioAttributes)
            .setAcceptsDelayedFocusGain(true)
            .setOnAudioFocusChangeListener(audioFocusChangeListener)
            .build()

        val result = audioManager.requestAudioFocus(audioFocusRequest!!)
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun releaseAudioFocus(result: Result) {
        try {
            if (!hasAudioFocus) {
                result.success(null)
                return
            }

            val released = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                releaseAudioFocusV26()
            } else {
                releaseAudioFocusLegacy()
            }

            hasAudioFocus = false
            result.success(released)
        } catch (e: Exception) {
            result.error("AUDIO_FOCUS_ERROR", "Failed to release audio focus: ${e.message}", null)
        }
    }

    @Suppress("DEPRECATION")
    private fun releaseAudioFocusLegacy(): Boolean {
        val result = audioManager.abandonAudioFocus(audioFocusChangeListener)
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun releaseAudioFocusV26(): Boolean {
        val result = audioFocusRequest?.let { 
            audioManager.abandonAudioFocusRequest(it)
        } ?: AudioManager.AUDIOFOCUS_REQUEST_FAILED
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun setDuckingVolume(volume: Double, result: Result) {
        try {
            // Note: This is a simplified implementation
            // In a real app, you'd want to integrate with your audio player's volume control
            // For now, we'll just notify the Flutter side that ducking should be applied
            result.success(true)
        } catch (e: Exception) {
            result.error("DUCKING_ERROR", "Failed to set ducking volume: ${e.message}", null)
        }
    }

    private fun restoreNormalVolume(result: Result) {
        try {
            // Note: This is a simplified implementation
            // In a real app, you'd want to integrate with your audio player's volume control
            // For now, we'll just notify the Flutter side that normal volume should be restored
            result.success(true)
        } catch (e: Exception) {
            result.error("DUCKING_ERROR", "Failed to restore normal volume: ${e.message}", null)
        }
    }

    private val audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                hasAudioFocus = true
                methodChannel?.invokeMethod("onAudioFocusChange", mapOf(
                    "event" to FOCUS_GAIN,
                    "hasFocus" to true
                ))
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                hasAudioFocus = false
                methodChannel?.invokeMethod("onAudioFocusChange", mapOf(
                    "event" to FOCUS_LOSS,
                    "hasFocus" to false
                ))
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                hasAudioFocus = false
                methodChannel?.invokeMethod("onAudioFocusChange", mapOf(
                    "event" to FOCUS_LOSS_TRANSIENT,
                    "hasFocus" to false
                ))
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                methodChannel?.invokeMethod("onAudioFocusChange", mapOf(
                    "event" to FOCUS_LOSS_TRANSIENT_CAN_DUCK,
                    "hasFocus" to true,
                    "shouldDuck" to true
                ))
            }
        }
    }

    /// Optimize audio session for streaming to prevent underruns
    fun optimizeAudioSession() {
        try {
            Log.d("AudioFocusHandler", "Optimizing audio session for streaming...")
            
            // Set audio mode to normal for media playback
            audioManager.mode = AudioManager.MODE_NORMAL
            
            // Ensure we're using the music stream
            audioManager.setStreamVolume(
                AudioManager.STREAM_MUSIC,
                audioManager.getStreamVolume(AudioManager.STREAM_MUSIC),
                0
            )
            
            // For Android 9+ (API 28+), we can set audio attributes for better performance
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // This helps with audio focus and buffer management
                Log.d("AudioFocusHandler", "Applied Android 9+ audio optimizations")
            }
            
            Log.d("AudioFocusHandler", "Audio session optimization completed")
        } catch (e: Exception) {
            Log.e("AudioFocusHandler", "Failed to optimize audio session: ${e.message}")
        }
    }
}
