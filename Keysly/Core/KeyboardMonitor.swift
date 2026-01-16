import Foundation
import Carbon
import Cocoa
import Observation

// MARK: - Keyboard Monitor Delegate

protocol KeyboardMonitorDelegate: AnyObject, Sendable {
    @MainActor func keyboardMonitor(_ monitor: KeyboardMonitor, didCaptureUnknownCombo keyCombo: KeyCombo)
    @MainActor func keyboardMonitor(_ monitor: KeyboardMonitor, didTriggerShortcut shortcut: Shortcut)
}

// MARK: - Keyboard Monitor

@Observable
final class KeyboardMonitor: @unchecked Sendable {
    
    weak var delegate: KeyboardMonitorDelegate?
    
    private(set) var isMonitoring = false
    private(set) var currentKeyDisplay: String = ""
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private let shortcutStore: ShortcutStore
    
    init(shortcutStore: ShortcutStore) {
        self.shortcutStore = shortcutStore
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Control
    
    func start() {
        guard !isMonitoring else { return }
        
        // Create event tap for key down events
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        // Store self pointer for callback
        let selfPtr = Unmanaged.passRetained(self).toOpaque()
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon).takeUnretainedValue()
                return monitor.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: selfPtr
        ) else {
            print("Failed to create event tap. Accessibility permission may not be granted.")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        isMonitoring = true
    }
    
    func stop() {
        guard isMonitoring else { return }
        
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
            runLoopSource = nil
            eventTap = nil
        }
        
        isMonitoring = false
    }
    
    // MARK: - Event Handling
    
    private func handleEvent(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        
        // Handle tap disabled event (system might disable it)
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }
        
        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }
        
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags
        let modifiers = KeyModifiers.from(cgEventFlags: flags)
        
        // Only intercept if at least one modifier is pressed
        guard !modifiers.isEmpty else {
            return Unmanaged.passUnretained(event)
        }
        
        let keyString = Self.keyString(for: keyCode)
        let keyCombo = KeyCombo(keyCode: keyCode, keyString: keyString, modifiers: modifiers)
        
        // Update display
        Task { @MainActor in
            self.currentKeyDisplay = keyCombo.displayString
        }
        
        // Check if shortcut exists
        let frontAppBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        if let shortcut = shortcutStore.shortcut(for: keyCombo, contextBundleId: frontAppBundleId) {
            // Known shortcut - execute it
            Task { @MainActor in
                self.delegate?.keyboardMonitor(self, didTriggerShortcut: shortcut)
            }
            // Consume the event
            return nil
        } else {
            // Unknown shortcut - prompt for assignment
            Task { @MainActor in
                self.delegate?.keyboardMonitor(self, didCaptureUnknownCombo: keyCombo)
            }
            // Don't consume - let it pass through (user might want system shortcut)
            return Unmanaged.passUnretained(event)
        }
    }
    
    // MARK: - Key Code to String
    
    static func keyString(for keyCode: UInt16) -> String {
        // Common key mappings
        let keyMap: [UInt16: String] = [
            // Letters
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".",
            
            // Function keys
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
            98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
            
            // Special keys
            36: "Return", 48: "Tab", 49: "Space", 51: "Delete", 53: "Escape",
            76: "Enter", 115: "Home", 119: "End", 116: "PageUp", 121: "PageDown",
            123: "←", 124: "→", 125: "↓", 126: "↑",
            
            // Numpad
            65: ".", 67: "*", 69: "+", 75: "/", 78: "-", 81: "=",
            82: "0", 83: "1", 84: "2", 85: "3", 86: "4", 87: "5",
            88: "6", 89: "7", 91: "8", 92: "9"
        ]
        
        return keyMap[keyCode] ?? "Key\(keyCode)"
    }
}
