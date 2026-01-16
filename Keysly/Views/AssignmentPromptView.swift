import SwiftUI

struct AssignmentPromptView: View {
    
    let keyCombo: KeyCombo
    let editingShortcut: Shortcut?
    let onSave: (Action) -> Void
    let onCancel: () -> Void
    
    @State private var selectedActionType: ActionType = .app
    @State private var selectedApp: AppInfo?
    @State private var urlString: String = "https://"
    @State private var scriptContent: String = ""
    @State private var scriptType: ScriptType = .shell
    @State private var selectedSystemAction: SystemActionType = .toggleDarkMode
    @State private var didInitialize = false
    
    // Dark theme colors
    private let bgPrimary = Color(red: 0.08, green: 0.08, blue: 0.10)
    private let bgSecondary = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let bgTertiary = Color(red: 0.16, green: 0.16, blue: 0.18)
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 1.0)
    private let textPrimary = Color.white
    private let textSecondary = Color(white: 0.6)
    private let textTertiary = Color(white: 0.4)
    
    enum ActionType: String, CaseIterable {
        case app = "App"
        case url = "URL"
        case script = "Script"
        case system = "System"
    }
    
    var body: some View {
        ZStack {
            bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    // Key combo display
                    HStack(spacing: 6) {
                        ForEach(keyComboKeys, id: \.self) { key in
                            Text(key)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(accentColor)
                                .frame(minWidth: 32, minHeight: 32)
                                .background(accentColor.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    
                    Text(editingShortcut != nil ? "Edit Action" : "Assign Action")
                        .font(.callout)
                        .foregroundStyle(textSecondary)
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
                
                Rectangle()
                    .fill(bgTertiary)
                    .frame(height: 1)
                
                // Action type picker
                VStack(spacing: 20) {
                    HStack(spacing: 0) {
                        ForEach(ActionType.allCases, id: \.self) { type in
                            Button {
                                selectedActionType = type
                            } label: {
                                Text(type.rawValue)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(selectedActionType == type ? textPrimary : textTertiary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedActionType == type ? bgTertiary : .clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .background(bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Configuration
                    actionConfiguration
                        .frame(height: 100)
                }
                .padding(24)
                
                Spacer()
                
                // Footer
                Rectangle()
                    .fill(bgTertiary)
                    .frame(height: 1)
                
                HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    .keyboardShortcut(.escape, modifiers: [])
                    
                    Spacer()
                    
                    Button {
                        if let action = buildAction() {
                            onSave(action)
                        }
                    } label: {
                        Text(editingShortcut != nil ? "Update" : "Save")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(canSave ? accentColor : accentColor.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSave)
                    .keyboardShortcut(.return, modifiers: .command)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            initializeFromEditing()
        }
    }
    
    private var keyComboKeys: [String] {
        var keys: [String] = []
        if keyCombo.modifiers.contains(.control) { keys.append("⌃") }
        if keyCombo.modifiers.contains(.option) { keys.append("⌥") }
        if keyCombo.modifiers.contains(.shift) { keys.append("⇧") }
        if keyCombo.modifiers.contains(.command) { keys.append("⌘") }
        keys.append(keyCombo.keyString.uppercased())
        return keys
    }
    
    private func initializeFromEditing() {
        guard !didInitialize, let shortcut = editingShortcut else { return }
        didInitialize = true
        
        switch shortcut.action {
        case .launchApp(let bundleId, let name):
            selectedActionType = .app
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                selectedApp = AppInfo(id: bundleId, name: name, icon: icon)
            }
        case .openURL(let url, _):
            selectedActionType = .url
            urlString = url.absoluteString
        case .runInlineScript(let script, let type):
            selectedActionType = .script
            scriptContent = script
            scriptType = type
        case .runScript(let path, let type):
            selectedActionType = .script
            scriptContent = "# Script at: \(path)"
            scriptType = type
        case .systemAction(let type):
            selectedActionType = .system
            selectedSystemAction = type
        case .chain:
            selectedActionType = .app
        }
    }
    
    // MARK: - Action Configuration
    
    @ViewBuilder
    private var actionConfiguration: some View {
        switch selectedActionType {
        case .app:
            appPicker
        case .url:
            urlInput
        case .script:
            scriptInput
        case .system:
            systemActionPicker
        }
    }
    
    private var appPicker: some View {
        AppPickerButton(
            selectedApp: $selectedApp,
            bgSecondary: bgSecondary,
            bgTertiary: bgTertiary,
            textPrimary: textPrimary,
            textSecondary: textSecondary
        )
    }
    
    private var urlInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Website URL")
                .font(.caption)
                .foregroundStyle(textSecondary)
            
            TextField("https://example.com", text: $urlString)
                .textFieldStyle(.plain)
                .font(.callout)
                .padding(12)
                .background(bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var scriptInput: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                ForEach(ScriptType.allCases, id: \.self) { type in
                    Button {
                        scriptType = type
                    } label: {
                        Text(type.rawValue)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(scriptType == type ? textPrimary : textTertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(scriptType == type ? bgTertiary : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            TextEditor(text: $scriptContent)
                .font(.system(size: 11, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var systemActionPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("System Action")
                .font(.caption)
                .foregroundStyle(textSecondary)
            
            Picker("", selection: $selectedSystemAction) {
                ForEach(SystemActionType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.iconName).tag(type)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
    }
    
    // MARK: - Logic
    
    private var canSave: Bool {
        switch selectedActionType {
        case .app: return selectedApp != nil
        case .url: return URL(string: urlString) != nil && urlString.count > 8
        case .script: return !scriptContent.isEmpty
        case .system: return true
        }
    }
    
    private func buildAction() -> Action? {
        switch selectedActionType {
        case .app:
            guard let app = selectedApp else { return nil }
            return .launchApp(bundleId: app.bundleId, appName: app.name)
        case .url:
            guard let url = URL(string: urlString) else { return nil }
            return .openURL(url: url, name: nil)
        case .script:
            return .runInlineScript(script: scriptContent, type: scriptType)
        case .system:
            return .systemAction(selectedSystemAction)
        }
    }
}

// MARK: - App Info

struct AppInfo: Identifiable, Hashable {
    let id: String
    var bundleId: String { id }
    let name: String
    let icon: NSImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - App Picker Button

struct AppPickerButton: View {
    @Binding var selectedApp: AppInfo?
    let bgSecondary: Color
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    
    @State private var showingPicker = false
    @State private var apps: [AppInfo] = []
    @State private var searchText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Application")
                .font(.caption)
                .foregroundStyle(textSecondary)
            
            Button {
                loadApps()
                showingPicker = true
            } label: {
                HStack {
                    if let app = selectedApp {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                        Text(app.name)
                            .foregroundStyle(textPrimary)
                    } else {
                        Text("Select an app...")
                            .foregroundStyle(textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(textSecondary)
                }
                .padding(12)
                .background(bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingPicker) {
                VStack(spacing: 0) {
                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(12)
                    
                    Divider()
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredApps) { app in
                                Button {
                                    selectedApp = app
                                    showingPicker = false
                                } label: {
                                    HStack(spacing: 10) {
                                        if let icon = app.icon {
                                            Image(nsImage: icon)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                        Text(app.name)
                                            .font(.callout)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(height: 240)
                }
                .frame(width: 280)
            }
        }
    }
    
    private var filteredApps: [AppInfo] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func loadApps() {
        guard apps.isEmpty else { return }
        
        var loaded: [AppInfo] = []
        let paths = ["/Applications", "/System/Applications", NSHomeDirectory() + "/Applications"]
        
        for path in paths {
            let url = URL(fileURLWithPath: path)
            guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { continue }
            
            for appURL in contents where appURL.pathExtension == "app" {
                if let bundle = Bundle(url: appURL), let bundleId = bundle.bundleIdentifier {
                    let name = FileManager.default.displayName(atPath: appURL.path)
                    let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                    loaded.append(AppInfo(id: bundleId, name: name, icon: icon))
                }
            }
        }
        
        apps = loaded.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
