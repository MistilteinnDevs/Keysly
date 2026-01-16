import SwiftUI

enum AppTab: String, CaseIterable {
    case shortcuts = "Shortcuts"
    case wiki = "Wiki"
}

struct ContentView: View {
    
    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppTab = .shortcuts
    @State private var isRecording = false
    @State private var recordedKeyCombo: KeyCombo?
    @State private var showingAssignment = false
    @State private var editingShortcut: Shortcut?
    @State private var conflictError: String?
    @State private var shortcutToDelete: Shortcut?
    @State private var eventMonitor: Any?
    
    // Dark theme colors
    private let bgPrimary = Color(red: 0.08, green: 0.08, blue: 0.10)
    private let bgSecondary = Color(red: 0.12, green: 0.12, blue: 0.14)
    private let bgTertiary = Color(red: 0.16, green: 0.16, blue: 0.18)
    private let accentColor = Color(red: 0.4, green: 0.6, blue: 1.0)
    private let textPrimary = Color.white
    private let textSecondary = Color(white: 0.6)
    private let textTertiary = Color(white: 0.4)
    
    var body: some View {
        ZStack {
            bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if !appState.permissionManager.isFullyReady {
                    permissionsNeeded
                } else if isRecording {
                    recordingView
                } else if showingAssignment, let keyCombo = recordedKeyCombo {
                    assignmentView(keyCombo: keyCombo)
                } else {
                    mainContent
                }
            }
        }
        .frame(width: 520, height: 480)
        .preferredColorScheme(.dark)
        // Conflict alert
        .alert("Shortcut Conflict", isPresented: .init(
            get: { conflictError != nil },
            set: { if !$0 { conflictError = nil } }
        )) {
            Button("OK") { conflictError = nil }
        } message: {
            Text(conflictError ?? "")
        }
        // Delete confirmation
        .alert("Delete Shortcut?", isPresented: .init(
            get: { shortcutToDelete != nil },
            set: { if !$0 { shortcutToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { shortcutToDelete = nil }
            Button("Delete", role: .destructive) {
                if let shortcut = shortcutToDelete {
                    withAnimation { appState.shortcutStore.deleteShortcut(id: shortcut.id) }
                }
                shortcutToDelete = nil
            }
        } message: {
            if let shortcut = shortcutToDelete {
                Text("Remove '\(shortcut.keyCombo.displayString)' shortcut?")
            }
        }
    }
    
    // MARK: - Assignment View
    
    private func assignmentView(keyCombo: KeyCombo) -> some View {
        AssignmentPromptView(
            keyCombo: keyCombo,
            editingShortcut: editingShortcut,
            onSave: { action in
                if let conflict = appState.shortcutStore.findConflict(for: keyCombo, excludingId: editingShortcut?.id) {
                    conflictError = "'\(keyCombo.displayString)' is already used for '\(conflict.action.displayName)'"
                    return
                }
                
                if let editing = editingShortcut {
                    var updated = editing
                    updated.keyCombo = keyCombo
                    updated.action = action
                    try? appState.shortcutStore.updateShortcut(updated)
                } else {
                    appState.saveShortcut(keyCombo: keyCombo, action: action)
                }
                showingAssignment = false
                recordedKeyCombo = nil
                editingShortcut = nil
            },
            onCancel: {
                showingAssignment = false
                recordedKeyCombo = nil
                editingShortcut = nil
            }
        )
    }
    
    // MARK: - Permissions Needed
    
    private var permissionsNeeded: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "keyboard")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(accentColor)
            }
            
            VStack(spacing: 12) {
                Text("Enable Keysly")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(textPrimary)
                
                Text("Grant Accessibility access to\ncapture global keyboard shortcuts")
                    .font(.callout)
                    .foregroundStyle(textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                appState.permissionManager.openAccessibilitySettings()
            } label: {
                Text("Open Settings")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(accentColor)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(40)
    }
    
    // MARK: - Recording View
    
    private var recordingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    .frame(width: 100, height: 100)
                Image(systemName: "waveform")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(.red)
            }
            
            VStack(spacing: 8) {
                Text("Listening...")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(textPrimary)
                
                Text("Press any key combination")
                    .font(.callout)
                    .foregroundStyle(textSecondary)
            }
            
            Button("Cancel") {
                stopRecording()
            }
            .buttonStyle(.bordered)
            .tint(.gray)
            
            Spacer()
        }
        .padding(40)
        .onAppear { startKeyCapture() }
        .onDisappear { stopKeyCapture() }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            
            Rectangle()
                .fill(bgTertiary)
                .frame(height: 1)
            
            // Tab content
            if selectedTab == .shortcuts {
                shortcutsContent
            } else {
                WikiContentView(
                    bgSecondary: bgSecondary,
                    bgTertiary: bgTertiary,
                    accentColor: accentColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary
                )
            }
        }
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(selectedTab == tab ? textPrimary : textTertiary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? bgTertiary : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(bgSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Spacer()
            
            if selectedTab == .shortcuts {
                // Count badge
                Text("\(appState.shortcutStore.shortcuts.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(bgSecondary)
                    .clipShape(Capsule())
                
                // Add button
                Button {
                    editingShortcut = nil
                    startRecording()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                        Text("New")
                            .font(.callout.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Shortcuts Content
    
    private var shortcutsContent: some View {
        Group {
            if appState.shortcutStore.shortcuts.isEmpty {
                emptyState
            } else {
                shortcutsList
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "keyboard")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(textTertiary)
            
            VStack(spacing: 6) {
                Text("No shortcuts yet")
                    .font(.callout)
                    .foregroundStyle(textSecondary)
                Text("Click New to create your first shortcut")
                    .font(.caption)
                    .foregroundStyle(textTertiary)
            }
            
            Spacer()
        }
    }
    
    private var shortcutsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(appState.shortcutStore.shortcuts) { shortcut in
                    shortcutRow(shortcut)
                }
            }
            .padding(20)
        }
    }
    
    private func shortcutRow(_ shortcut: Shortcut) -> some View {
        HStack(spacing: 16) {
            // Key combo
            keyBadges(for: shortcut.keyCombo)
            
            // App icon
            if case .launchApp(let bundleId, _) = shortcut.action {
                appIcon(bundleId: bundleId)
            }
            
            // Action info
            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.action.displayName)
                    .font(.callout)
                    .foregroundStyle(textPrimary)
                    .lineLimit(1)
                
                Text("\(shortcut.useCount) uses")
                    .font(.caption2)
                    .foregroundStyle(textTertiary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                editingShortcut = shortcut
                recordedKeyCombo = shortcut.keyCombo
                showingAssignment = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                shortcutToDelete = shortcut
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Key Badges
    
    private func keyBadges(for keyCombo: KeyCombo) -> some View {
        HStack(spacing: 6) {
            if keyCombo.modifiers.contains(.control) {
                keyBadge("⌃")
            }
            if keyCombo.modifiers.contains(.option) {
                keyBadge("⌥")
            }
            if keyCombo.modifiers.contains(.shift) {
                keyBadge("⇧")
            }
            if keyCombo.modifiers.contains(.command) {
                keyBadge("⌘")
            }
            keyBadge(keyCombo.keyString.uppercased())
        }
    }
    
    private func keyBadge(_ key: String) -> some View {
        Text(key)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(accentColor)
            .frame(minWidth: 28, minHeight: 28)
            .background(accentColor.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    // MARK: - App Icon
    
    private func appIcon(bundleId: String) -> some View {
        Group {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    // MARK: - Key Capture
    
    private func startRecording() {
        isRecording = true
        recordedKeyCombo = nil
    }
    
    private func stopRecording() {
        isRecording = false
        recordedKeyCombo = nil
        editingShortcut = nil
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func startKeyCapture() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard self.isRecording else { return event }
            
            let modifiers = KeyModifiers.from(cgEventFlags: CGEventFlags(rawValue: UInt64(event.modifierFlags.rawValue)))
            guard !modifiers.isEmpty else { return event }
            
            let keyString = KeyboardMonitor.keyString(for: event.keyCode)
            let systemKeys = ["V", "C", "X", "Z", "A", "S", "Q", "W", "Tab"]
            if modifiers == .command && systemKeys.contains(keyString.uppercased()) {
                return event
            }
            
            let keyCombo = KeyCombo(keyCode: event.keyCode, keyString: keyString, modifiers: modifiers)
            
            if self.editingShortcut == nil,
               let conflict = self.appState.shortcutStore.findConflict(for: keyCombo, excludingId: nil) {
                self.conflictError = "'\(keyCombo.displayString)' is already used for '\(conflict.action.displayName)'"
                self.isRecording = false
                return nil
            }
            
            self.recordedKeyCombo = keyCombo
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isRecording = false
                self.showingAssignment = true
            }
            
            return nil
        }
    }
    
    private func stopKeyCapture() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// MARK: - Wiki Content View

struct WikiContentView: View {
    let bgSecondary: Color
    let bgTertiary: Color
    let accentColor: Color
    let textPrimary: Color
    let textSecondary: Color
    
    @State private var searchText = ""
    @State private var selectedCategory: ShortcutCategory = .common
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(ShortcutCategory.allCases, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                    .frame(width: 16)
                                Text(category.title)
                                    .font(.caption)
                                Spacer()
                            }
                            .foregroundStyle(selectedCategory == category ? .white : textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? accentColor : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }
            .frame(width: 150)
            .background(bgSecondary)
            
            Rectangle()
                .fill(bgTertiary)
                .frame(width: 1)
            
            // Content
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // Search
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(textSecondary)
                        TextField("Search shortcuts...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.callout)
                    }
                    .padding(10)
                    .background(bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Category header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedCategory.title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(textPrimary)
                        Text(selectedCategory.description)
                            .font(.caption)
                            .foregroundStyle(textSecondary)
                    }
                    .padding(.top, 8)
                    
                    // Shortcuts
                    ForEach(filteredShortcuts, id: \.keys) { shortcut in
                        wikiRow(shortcut)
                    }
                }
                .padding(20)
            }
        }
    }
    
    private var filteredShortcuts: [WikiShortcut] {
        let categoryShortcuts = WikiData.shortcuts(for: selectedCategory)
        if searchText.isEmpty { return categoryShortcuts }
        return categoryShortcuts.filter {
            $0.keys.localizedCaseInsensitiveContains(searchText) ||
            $0.action.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func wikiRow(_ shortcut: WikiShortcut) -> some View {
        HStack(spacing: 16) {
            // Keys
            HStack(spacing: 4) {
                ForEach(Array(shortcut.keyParts.enumerated()), id: \.offset) { _, part in
                    if part == "+" {
                        Text("+")
                            .font(.caption2)
                            .foregroundStyle(textSecondary)
                    } else {
                        Text(part)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .frame(minWidth: 100, alignment: .leading)
            
            Text(shortcut.action)
                .font(.callout)
                .foregroundStyle(textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
