import Foundation
import CoreGraphics

// MARK: - Key Modifiers

struct KeyModifiers: OptionSet, Codable, Hashable, Sendable {
    let rawValue: UInt
    
    static let command = KeyModifiers(rawValue: 1 << 0)
    static let option  = KeyModifiers(rawValue: 1 << 1)
    static let control = KeyModifiers(rawValue: 1 << 2)
    static let shift   = KeyModifiers(rawValue: 1 << 3)
    
    var symbols: String {
        var result = ""
        if contains(.control) { result += "⌃" }
        if contains(.option)  { result += "⌥" }
        if contains(.shift)   { result += "⇧" }
        if contains(.command) { result += "⌘" }
        return result
    }
    
    static func from(cgEventFlags: CGEventFlags) -> KeyModifiers {
        var modifiers: KeyModifiers = []
        if cgEventFlags.contains(.maskCommand) { modifiers.insert(.command) }
        if cgEventFlags.contains(.maskAlternate) { modifiers.insert(.option) }
        if cgEventFlags.contains(.maskControl) { modifiers.insert(.control) }
        if cgEventFlags.contains(.maskShift) { modifiers.insert(.shift) }
        return modifiers
    }
}

// MARK: - Key Combo

struct KeyCombo: Codable, Hashable, Sendable {
    let keyCode: UInt16
    let keyString: String
    let modifiers: KeyModifiers
    
    var displayString: String {
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        parts.append(keyString.uppercased())
        return parts.joined(separator: " + ")
    }
    
    /// Check if this combo has at least one modifier (required for global shortcuts)
    var isValid: Bool {
        !modifiers.isEmpty
    }
}

// MARK: - Shortcut

struct Shortcut: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var keyCombo: KeyCombo
    var action: Action
    var contextAppBundleId: String?  // nil = global shortcut
    var useCount: Int
    var createdAt: Date
    var lastUsedAt: Date?
    
    init(
        id: UUID = UUID(),
        keyCombo: KeyCombo,
        action: Action,
        contextAppBundleId: String? = nil
    ) {
        self.id = id
        self.keyCombo = keyCombo
        self.action = action
        self.contextAppBundleId = contextAppBundleId
        self.useCount = 0
        self.createdAt = Date()
        self.lastUsedAt = nil
    }
    
    mutating func recordUse() {
        useCount += 1
        lastUsedAt = Date()
    }
}
