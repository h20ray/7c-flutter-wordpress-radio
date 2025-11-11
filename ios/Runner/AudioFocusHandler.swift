import Foundation
import AVFoundation
import Flutter

class AudioFocusHandler: NSObject, FlutterPlugin {
    private var audioSession: AVAudioSession
    private var methodChannel: FlutterMethodChannel?
    private var hasAudioFocus = false
    
    // Focus event types
    static let FOCUS_GAIN = "focus_gain"
    static let FOCUS_LOSS = "focus_loss"
    static let FOCUS_LOSS_TRANSIENT = "focus_loss_transient"
    static let FOCUS_LOSS_TRANSIENT_CAN_DUCK = "focus_loss_transient_can_duck"
    
    init(audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.audioSession = audioSession
        super.init()
        setupAudioSession()
        setupNotifications()
    }
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_focus", binaryMessenger: registrar.messenger())
        let instance = AudioFocusHandler()
        instance.methodChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestAudioFocus":
            requestAudioFocus(result: result)
        case "releaseAudioFocus":
            releaseAudioFocus(result: result)
        case "setDuckingVolume":
            let args = call.arguments as? [String: Any]
            let volume = args?["volume"] as? Double ?? 0.3
            setDuckingVolume(volume: volume, result: result)
        case "restoreNormalVolume":
            restoreNormalVolume(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(false)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    private func requestAudioFocus(result: @escaping FlutterResult) {
        do {
            try audioSession.setActive(true)
            hasAudioFocus = true
            result(true)
        } catch {
            hasAudioFocus = false
            result(FlutterError(code: "AUDIO_FOCUS_ERROR", message: "Failed to request audio focus: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func releaseAudioFocus(result: @escaping FlutterResult) {
        do {
            try audioSession.setActive(false)
            hasAudioFocus = false
            result(true)
        } catch {
            result(FlutterError(code: "AUDIO_FOCUS_ERROR", message: "Failed to release audio focus: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func setDuckingVolume(volume: Double, result: @escaping FlutterResult) {
        // Note: This is a simplified implementation
        // In a real app, you'd want to integrate with your audio player's volume control
        // For now, we'll just notify the Flutter side that ducking should be applied
        result(true)
    }
    
    private func restoreNormalVolume(result: @escaping FlutterResult) {
        // Note: This is a simplified implementation
        // In a real app, you'd want to integrate with your audio player's volume control
        // For now, we'll just notify the Flutter side that normal volume should be restored
        result(true)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began - pause playback
            hasAudioFocus = false
            methodChannel?.invokeMethod("onAudioFocusChange", arguments: [
                "event": AudioFocusHandler.FOCUS_LOSS_TRANSIENT,
                "hasFocus": false
            ])
            
        case .ended:
            // Interruption ended - check if we should resume
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume playback
                    do {
                        try audioSession.setActive(true)
                        hasAudioFocus = true
                        methodChannel?.invokeMethod("onAudioFocusChange", arguments: [
                            "event": AudioFocusHandler.FOCUS_GAIN,
                            "hasFocus": true
                        ])
                    } catch {
                        print("Failed to resume audio session: \(error)")
                    }
                }
            }
            
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones disconnected - pause playback
            hasAudioFocus = false
            methodChannel?.invokeMethod("onAudioFocusChange", arguments: [
                "event": AudioFocusHandler.FOCUS_LOSS,
                "hasFocus": false
            ])
            
        case .newDeviceAvailable:
            // New audio device available - could resume if appropriate
            // This is implementation-specific based on your app's behavior
            
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
