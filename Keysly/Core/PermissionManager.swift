import Foundation
import ApplicationServices
import AppKit
import Observation

// MARK: - Permission Status

enum PermissionStatus: String, Sendable {
    case unknown = "Checking..."
    case notGranted = "Not Granted"
    case granted = "Ready"
    case waiting = "Waiting for permission..."
}

// MARK: - Permission Manager

@Observable
@MainActor
final class PermissionManager {
    
    private(set) var accessibilityStatus: PermissionStatus = .unknown
    private(set) var isFullyReady: Bool = false
    
    @MainActor private var pollingTimer: Timer?
    
    init() {
        checkPermissions()
        startPolling()
    }
    
    // MARK: - Permission Checks
    
    func checkPermissions() {
        let trusted = AXIsProcessTrusted()
        accessibilityStatus = trusted ? .granted : .notGranted
        isFullyReady = trusted
    }
    
    // MARK: - Request Permissions
    
    func requestAccessibility() {
        accessibilityStatus = .waiting
        
        // This will prompt the user if not already trusted
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if trusted {
            accessibilityStatus = .granted
            isFullyReady = true
        }
    }
    
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
        accessibilityStatus = .waiting
    }
    
    func openInputMonitoringSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Polling
    
    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkPermissions()
            }
        }
    }
}
