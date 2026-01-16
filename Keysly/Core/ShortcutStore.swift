import Foundation
import Observation

// MARK: - Shortcut Store

@Observable
final class ShortcutStore: @unchecked Sendable {
    
    private(set) var shortcuts: [Shortcut] = []
    private(set) var profiles: [Profile] = []
    private(set) var activeProfileId: UUID?
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var storageURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let keyslyDir = appSupport.appendingPathComponent("Keysly", isDirectory: true)
        try? fileManager.createDirectory(at: keyslyDir, withIntermediateDirectories: true)
        return keyslyDir
    }
    
    private var shortcutsFileURL: URL {
        storageURL.appendingPathComponent("shortcuts.json")
    }
    
    private var profilesFileURL: URL {
        storageURL.appendingPathComponent("profiles.json")
    }
    
    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }
    
    // MARK: - CRUD Operations
    
    func addShortcut(_ shortcut: Shortcut) throws {
        // Check for conflicts
        if let conflict = findConflict(for: shortcut.keyCombo, excludingId: shortcut.id) {
            throw ShortcutError.conflict(existing: conflict)
        }
        
        shortcuts.append(shortcut)
        save()
    }
    
    func updateShortcut(_ shortcut: Shortcut) throws {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) else {
            throw ShortcutError.notFound
        }
        
        // Check for conflicts with other shortcuts
        if let conflict = findConflict(for: shortcut.keyCombo, excludingId: shortcut.id) {
            throw ShortcutError.conflict(existing: conflict)
        }
        
        shortcuts[index] = shortcut
        save()
    }
    
    func deleteShortcut(id: UUID) {
        shortcuts.removeAll { $0.id == id }
        save()
    }
    
    func recordUse(id: UUID) {
        guard let index = shortcuts.firstIndex(where: { $0.id == id }) else { return }
        shortcuts[index].recordUse()
        save()
    }
    
    // MARK: - Lookup
    
    func shortcut(for keyCombo: KeyCombo, contextBundleId: String? = nil) -> Shortcut? {
        // First try context-specific shortcut
        if let bundleId = contextBundleId {
            if let contextShortcut = shortcuts.first(where: {
                $0.keyCombo == keyCombo && $0.contextAppBundleId == bundleId
            }) {
                return contextShortcut
            }
        }
        
        // Fall back to global shortcut
        return shortcuts.first { $0.keyCombo == keyCombo && $0.contextAppBundleId == nil }
    }
    
    func findConflict(for keyCombo: KeyCombo, excludingId: UUID? = nil) -> Shortcut? {
        shortcuts.first {
            $0.keyCombo == keyCombo &&
            $0.id != excludingId &&
            $0.contextAppBundleId == nil  // Only check global shortcuts for conflicts
        }
    }
    
    func search(query: String) -> [Shortcut] {
        guard !query.isEmpty else { return shortcuts }
        let lowercased = query.lowercased()
        return shortcuts.filter {
            $0.keyCombo.displayString.lowercased().contains(lowercased) ||
            $0.action.displayName.lowercased().contains(lowercased)
        }
    }
    
    // MARK: - Persistence
    
    private func load() {
        // Load shortcuts
        if let data = try? Data(contentsOf: shortcutsFileURL),
           let loaded = try? decoder.decode([Shortcut].self, from: data) {
            shortcuts = loaded
        }
        
        // Load profiles
        if let data = try? Data(contentsOf: profilesFileURL),
           let loaded = try? decoder.decode([Profile].self, from: data) {
            profiles = loaded
        }
        
        // Ensure default profile exists
        if profiles.isEmpty {
            profiles.append(Profile.defaultProfile)
        }
        
        // Set active profile to default if not set
        if activeProfileId == nil {
            activeProfileId = profiles.first(where: { $0.isDefault })?.id ?? profiles.first?.id
        }
    }
    
    private func save() {
        // Save shortcuts
        if let data = try? encoder.encode(shortcuts) {
            try? data.write(to: shortcutsFileURL, options: .atomic)
        }
        
        // Save profiles
        if let data = try? encoder.encode(profiles) {
            try? data.write(to: profilesFileURL, options: .atomic)
        }
    }
}

// MARK: - Errors

enum ShortcutError: LocalizedError {
    case conflict(existing: Shortcut)
    case notFound
    case invalidKeyCombo
    
    var errorDescription: String? {
        switch self {
        case .conflict(let existing):
            return "This shortcut conflicts with '\(existing.action.displayName)'"
        case .notFound:
            return "Shortcut not found"
        case .invalidKeyCombo:
            return "Invalid key combination. At least one modifier key is required."
        }
    }
}
