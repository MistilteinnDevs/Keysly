import SwiftUI

struct MenuBarView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
                .padding(.vertical, 8)
            
            // Status or shortcuts preview
            if !appState.permissionManager.isFullyReady {
                permissionSection
            } else {
                shortcutsPreview
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Actions
            actionsSection
        }
        .padding(12)
        .frame(width: 280)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Text("Keysly")
                .font(.headline)
            
            Spacer()
            
            statusBadge
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(appState.permissionManager.isFullyReady ? .green : .orange)
                .frame(width: 8, height: 8)
            
            Text(appState.permissionManager.isFullyReady ? "Active" : "Setup Required")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Permission Section
    
    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grant Accessibility access to enable global shortcuts.")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Button {
                appState.permissionManager.openAccessibilitySettings()
            } label: {
                Label("Open System Settings", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Shortcuts Preview
    
    private var shortcutsPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            if appState.shortcutStore.shortcuts.isEmpty {
                emptyState
            } else {
                ForEach(appState.shortcutStore.shortcuts.prefix(5)) { shortcut in
                    shortcutRow(shortcut)
                }
                
                if appState.shortcutStore.shortcuts.count > 5 {
                    Text("+\(appState.shortcutStore.shortcuts.count - 5) more")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "keyboard")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            
            Text("No shortcuts yet")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text("Press any key combo to create one")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private func shortcutRow(_ shortcut: Shortcut) -> some View {
        HStack {
            Text(shortcut.keyCombo.displayString)
                .font(.system(.callout, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(shortcut.action.displayName)
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            
            if shortcut.useCount > 0 {
                Text("×\(shortcut.useCount)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        VStack(spacing: 4) {
            Button {
                openSettings()
            } label: {
                Label("All Shortcuts", systemImage: "list.bullet")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
            
            Divider()
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Keysly", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    MenuBarView()
        .environment(AppState())
}
