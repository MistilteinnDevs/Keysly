import SwiftUI

struct ShortcutsListView: View {
    
    @Environment(AppState.self) private var appState
    
    // Theme Colors passed from parent
    let bgSecondary: Color
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentColor: Color
    
    var onEdit: (Shortcut) -> Void
    var onDelete: (Shortcut) -> Void
    
    @State private var searchText = ""
    @State private var hoveredShortcutId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            if !appState.shortcutStore.shortcuts.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundStyle(textSecondary)
                    
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .foregroundStyle(textPrimary)
                }
                .padding(12)
                .background(bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            
            // List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredShortcuts) { shortcut in
                        ShortcutCard(
                            shortcut: shortcut,
                            bgSecondary: bgSecondary,
                            bgTertiary: bgTertiary,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            accentColor: accentColor,
                            onEdit: { onEdit(shortcut) },
                            onDelete: { onDelete(shortcut) }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var filteredShortcuts: [Shortcut] {
        appState.shortcutStore.search(query: searchText)
    }
}

struct ShortcutCard: View {
    let shortcut: Shortcut
    let bgSecondary: Color
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentColor: Color
    
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            iconView
                .font(.system(size: 18))
                .frame(width: 24)
            
            // Info
            Text(shortcut.action.displayName)
                .font(.system(size: 13))
                .foregroundStyle(textPrimary)
            
            Spacer()
            
            // Actions (Only visible on hover)
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                            .foregroundStyle(textSecondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundStyle(textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }
            
            // Key Combo
            HStack(spacing: 4) {
                keyBadges
            }
            .opacity(isHovered ? 1 : 0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? bgSecondary : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch shortcut.action {
        case .launchApp(let bundleId, _):
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .frame(width: 18, height: 18)
            } else {
                Image(systemName: "app")
                    .foregroundStyle(textSecondary)
            }
        case .runShortcut:
            Image(systemName: "bolt")
                .foregroundStyle(textSecondary)
        case .openURL:
            Image(systemName: "globe")
                .foregroundStyle(textSecondary)
        case .systemAction:
            Image(systemName: "macwindow")
                .foregroundStyle(textSecondary)
        default:
            Image(systemName: "command")
                .foregroundStyle(textSecondary)
        }
    }
    
    private var keyBadges: some View {
        ForEach(shortcut.keyCombo.keyStrings, id: \.self) { key in
            Text(key)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(textSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(bgTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

// Helper for splitting key combo
extension KeyCombo {
    var keyStrings: [String] {
        var keys: [String] = []
        if modifiers.contains(.control) { keys.append("⌃") }
        if modifiers.contains(.option) { keys.append("⌥") }
        if modifiers.contains(.shift) { keys.append("⇧") }
        if modifiers.contains(.command) { keys.append("⌘") }
        keys.append(keyString.uppercased())
        return keys
    }
}
