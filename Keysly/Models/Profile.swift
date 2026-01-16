import Foundation

// MARK: - Profile

struct Profile: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var shortcuts: [Shortcut]
    var isDefault: Bool
    var activeForBundleIds: [String]     // Activate when these apps are frontmost
    var activeForFocusModes: [String]    // Activate during these focus modes
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        shortcuts: [Shortcut] = [],
        isDefault: Bool = false,
        activeForBundleIds: [String] = [],
        activeForFocusModes: [String] = []
    ) {
        self.id = id
        self.name = name
        self.shortcuts = shortcuts
        self.isDefault = isDefault
        self.activeForBundleIds = activeForBundleIds
        self.activeForFocusModes = activeForFocusModes
        self.createdAt = Date()
    }
    
    static var defaultProfile: Profile {
        Profile(name: "Default", isDefault: true)
    }
}
