import Foundation
import AppKit

// MARK: - Action Executor Protocol

protocol ActionExecutorProtocol: Sendable {
    func execute(_ action: Action) async throws
}

// MARK: - Action Executor

actor ActionExecutor: ActionExecutorProtocol {
    
    static let shared = ActionExecutor()
    
    func execute(_ action: Action) async throws {
        switch action {
        case .launchApp(let bundleId, _):
            try await launchApp(bundleId: bundleId)
            
        case .openURL(let url, _):
            try await openURL(url)
            
        case .runScript(let path, let type):
            try await runScript(at: path, type: type)
            
        case .runInlineScript(let script, let type):
            try await runInlineScript(script, type: type)
            
        case .systemAction(let actionType):
            try await executeSystemAction(actionType)
            
        case .runShortcut(let name):
            try await ShortcutsService.shared.run(shortcut: name)
            
        case .chain(let actions):
            for action in actions {
                try await execute(action)
            }
        }
    }
    
    // MARK: - App Launch
    
    private func launchApp(bundleId: String) async throws {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            throw ExecutorError.appNotFound(bundleId)
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        try await NSWorkspace.shared.openApplication(at: appURL, configuration: configuration)
    }
    
    // MARK: - URL
    
    private func openURL(_ url: URL) async throws {
        let success = NSWorkspace.shared.open(url)
        if !success {
            throw ExecutorError.urlOpenFailed(url)
        }
    }
    
    // MARK: - Scripts
    
    private func runScript(at path: String, type: ScriptType) async throws {
        let script = try String(contentsOfFile: path, encoding: .utf8)
        try await runInlineScript(script, type: type)
    }
    
    private func runInlineScript(_ script: String, type: ScriptType) async throws {
        switch type {
        case .shell:
            try await runShellScript(script)
        case .appleScript:
            try await runAppleScript(script)
        case .jxa:
            try await runJXA(script)
        }
    }
    
    private func runShellScript(_ script: String) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ExecutorError.scriptFailed(output)
        }
    }
    
    private func runAppleScript(_ script: String) async throws {
        var error: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            throw ExecutorError.scriptFailed(error.description)
        }
    }
    
    private func runJXA(_ script: String) async throws {
        // JXA runs via osascript with -l JavaScript
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-l", "JavaScript", "-e", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ExecutorError.scriptFailed(output)
        }
    }
    
    // MARK: - System Actions
    
    private func executeSystemAction(_ actionType: SystemActionType) async throws {
        switch actionType {
        case .sleep:
            // Use pmset for sleep
            try await runShellScript("pmset sleepnow")
            
        case .lock:
            // Use /usr/bin/open to lock screen via Keychain Access
            try await runShellScript("open -a ScreenSaverEngine")
            
        case .logout:
            // Use osascript with System Events (more reliable)
            try await runShellScript("osascript -e 'tell application id \"com.apple.systemevents\" to log out'")
            
        case .toggleDarkMode:
            // Use osascript via shell
            try await runShellScript("""
                osascript -e 'tell application id "com.apple.systemevents" to tell appearance preferences to set dark mode to not dark mode'
            """)
            
        case .emptyTrash:
            // Use osascript with Finder via Bundle ID to avoid -600 errors
            try await runShellScript("osascript -e 'tell application id \"com.apple.finder\" to empty trash'")
            
        case .showDesktop:
            // Use F11 key simulation or Expose
            try await runShellScript("open -a 'Mission Control' --args --toggle-show-desktop")
            
        case .missionControl:
            // Open Mission Control app
            try await runShellScript("open -a 'Mission Control'")
            
        case .launchpad:
            // Open Launchpad
            try await runShellScript("open -a Launchpad")
            
        case .notification:
            // Open Notification Center via shortcut simulation
            try await runShellScript("open -g 'x-apple.systempreferences:com.apple.preference.notifications'")
        }
    }
}

// MARK: - Errors

enum ExecutorError: LocalizedError {
    case appNotFound(String)
    case urlOpenFailed(URL)
    case scriptFailed(String)
    case unsupportedAction
    
    var errorDescription: String? {
        switch self {
        case .appNotFound(let bundleId):
            return "Application not found: \(bundleId)"
        case .urlOpenFailed(let url):
            return "Failed to open URL: \(url)"
        case .scriptFailed(let message):
            return "Script failed: \(message)"
        case .unsupportedAction:
            return "This action is not supported"
        }
    }
}
