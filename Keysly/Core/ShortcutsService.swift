import Foundation

actor ShortcutsService {
    
    static let shared = ShortcutsService()
    
    enum ShortcutsError: Error, LocalizedError {
        case executionFailed(String)
        case listingFailed(String)
        case shortcutsNotAvailable
        
        var errorDescription: String? {
            switch self {
            case .executionFailed(let msg): return "Failed to run shortcut: \(msg)"
            case .listingFailed(let msg): return "Failed to list shortcuts: \(msg)"
            case .shortcutsNotAvailable: return "Shortcuts.app is not available on this system"
            }
        }
    }
    
    private let shortcutsPath = "/usr/bin/shortcuts"
    
    // MARK: - API
    
    func listShortcuts() async throws -> [String] {
        guard FileManager.default.fileExists(atPath: shortcutsPath) else {
            throw ShortcutsError.shortcutsNotAvailable
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: shortcutsPath)
        process.arguments = ["list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        if process.terminationStatus != 0 {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ShortcutsError.listingFailed(errorMsg)
        }
        
        guard let output = String(data: data, encoding: .utf8) else { return [] }
        
        // Output is one shortcut name per line
        return output
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .sorted()
    }
    
    func run(shortcut: String) async throws {
        guard FileManager.default.fileExists(atPath: shortcutsPath) else {
            throw ShortcutsError.shortcutsNotAvailable
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: shortcutsPath)
        process.arguments = ["run", shortcut]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ShortcutsError.executionFailed(errorMsg)
        }
    }
}
