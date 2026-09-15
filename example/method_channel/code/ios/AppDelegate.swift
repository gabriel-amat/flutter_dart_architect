import UIKit
import Flutter
import LocalAuthentication

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    private let securityChannelName = "com.architect.enterprise/security"
    private let hardwareEventsChannelName = "com.architect.enterprise/hardware_events"
    
    private var eventSink: FlutterEventSink?
    private var timer: Timer?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        // 1. MethodChannel setup
        let securityChannel = FlutterMethodChannel(
            name: securityChannelName,
            binaryMessenger: controller.binaryMessenger
        )

        securityChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "getSecurityStatus":
                let isJailbroken = self.checkJailbreak()
                let data: [String: Any] = [
                    "isCompromised": isJailbroken,
                    "osVersion": "iOS " + UIDevice.current.systemVersion,
                    "securityPatchLevel": "Latest Secure Enclave",
                    "hasSecureHardware": true
                ]
                result(data)
                
            case "verifyBiometrics":
                let context = LAContext()
                var error: NSError?
                let reason = (call.arguments as? [String: Any])?["promptReason"] as? String ?? "Biometric Verification"
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evalError in
                        DispatchQueue.main.async {
                            if success {
                                result(true)
                            } else {
                                result(FlutterError(code: "AUTH_FAILED", message: evalError?.localizedDescription, details: nil))
                            }
                        }
                    }
                } else {
                    result(FlutterError(code: "BIOMETRICS_UNAVAILABLE", message: error?.localizedDescription, details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // 2. EventChannel setup
        let hardwareChannel = FlutterEventChannel(
            name: hardwareEventsChannelName,
            binaryMessenger: controller.binaryMessenger
        )
        hardwareChannel.setStreamHandler(self)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // FlutterStreamHandler implementation
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        var counter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.eventSink?("iOS Secure Pulse #\(counter) (Thermal: Nominal)")
            counter += 1
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        timer?.invalidate()
        timer = nil
        eventSink = nil
        return nil
    }

    private func checkJailbreak() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let fileManager = FileManager.default
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt"
        ]
        return paths.contains { fileManager.fileExists(atPath: $0) }
        #endif
    }
}
