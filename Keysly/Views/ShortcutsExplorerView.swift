import SwiftUI

struct ShortcutsExplorerView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("compactView") private var compactView = false
    
    // Theme Colors (Adaptive)
    private var bgPrimary: Color {
        colorScheme == .dark ? Color(hex: 0x1C1C1E) : Color(hex: 0xFFFFFF)
    }
    private var bgSecondary: Color {
        colorScheme == .dark ? Color(hex: 0x2C2C2E) : Color(hex: 0xF5F5F7)
    }
    private var bgTertiary: Color {
        colorScheme == .dark ? Color(hex: 0x3A3A3C) : Color(hex: 0xE5E5EB)
    }
    private var accentColor: Color {
        Color(hex: 0xFF9500)
    }
    private var textPrimary: Color {
        colorScheme == .dark ? .white : Color(hex: 0x000000)
    }
    private var textSecondary: Color {
        colorScheme == .dark ? Color(hex: 0x8E8E93) : Color(hex: 0x6E6E73)
    }
    
    // Navigation
    enum NavigationSelection: Hashable {
        case all
        case tag(String)
        
        var title: String {
            switch self {
            case .all: return "All Shortcuts"
            case .tag(let name): return "#" + name
            }
        }
        
        var icon: String {
            switch self {
            case .all: return "bolt.rectangle.fill"
            case .tag: return "tag.fill"
            }
        }
    }
    
    @State private var selection: NavigationSelection = .all
    @State private var searchText = ""
    @State private var selectedShortcut: Shortcut?
    
    var onAdd: () -> Void
    var onEdit: (Shortcut) -> Void
    var onDelete: (Shortcut) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            sidebarView
            mainContentView
        }
        .sheet(item: $selectedShortcut) { shortcut in
            ShortcutDetailView(
                shortcut: shortcut,
                onClose: { selectedShortcut = nil },
                onEdit: {
                    selectedShortcut = nil
                    onEdit(shortcut)
                },
                onDelete: {
                    selectedShortcut = nil
                    onDelete(shortcut)
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            searchBar
            sidebarList
        }
        .frame(width: 220)
        .background(bgSecondary.opacity(0.5))
        .overlay(
            Rectangle()
                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .frame(width: 1),
            alignment: .trailing
        )
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(textSecondary)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(textPrimary)
        }
        .padding(8)
        .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
        )
        .padding(12)
    }
    
    private var sidebarList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                // "All Shortcuts" Item
                sidebarButton(for: .all)
                
                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                
                // Tags List
                if !uniqueTags.isEmpty {
                    Text("TAGS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)
                    
                    ForEach(uniqueTags, id: \.self) { tag in
                        sidebarButton(for: .tag(tag))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(selection.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(textPrimary)
                
                Spacer()
                
                // Add Button (Moved to Header)
                Button {
                    onAdd()
                } label: {
                    Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold)) // Slightly larger
                    .foregroundStyle(textPrimary)
                    .padding(8)
                    .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            .padding(.bottom, 24)
            
            ScrollView {
                if filteredShortcuts.isEmpty {
                    emptyState
                } else {
                    if compactView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 160), spacing: 16)], spacing: 16) {
                            ForEach(filteredShortcuts) { shortcut in
                                CompactShortcutCard(
                                    shortcut: shortcut,
                                    bgPrimary: bgPrimary,
                                    bgSecondary: bgSecondary,
                                    bgTertiary: bgTertiary,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    accentColor: accentColor
                                )
                                .onTapGesture {
                                    selectedShortcut = shortcut
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(filteredShortcuts) { shortcut in
                                ShortcutExplorerCard(
                                    shortcut: shortcut,
                                    bgPrimary: bgPrimary,
                                    bgSecondary: bgSecondary,
                                    bgTertiary: bgTertiary,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    accentColor: accentColor
                                )
                                .onTapGesture {
                                    selectedShortcut = shortcut
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private var uniqueTags: [String] {
        let tags = appState.shortcutStore.shortcuts.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    private var filteredShortcuts: [Shortcut] {
        let shortcuts = appState.shortcutStore.shortcuts
        
        let initialFilter: [Shortcut]
        switch selection {
        case .all:
            initialFilter = shortcuts
        case .tag(let tag):
            initialFilter = shortcuts.filter { $0.tags.contains(tag) }
        }
        
        if searchText.isEmpty { return initialFilter }
        return initialFilter.filter {
            $0.action.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.keyCombo.displayString.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Components
    
    private func sidebarButton(for item: NavigationSelection) -> some View {
        Button {
            selection = item
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                    .foregroundStyle(selection == item ? .white : textPrimary)
                
                Text(item == .all ? "All Shortcuts" : item.title) // title handles # prefix
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selection == item ? .white : textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                // Count Badge
                let count = count(for: item)
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(selection == item ? .white.opacity(0.8) : textSecondary.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selection == item ? accentColor : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    private func count(for item: NavigationSelection) -> Int {
        switch item {
        case .all:
            return appState.shortcutStore.shortcuts.count
        case .tag(let tag):
            return appState.shortcutStore.shortcuts.filter { $0.tags.contains(tag) }.count
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(textSecondary.opacity(0.5))
            Text("No shortcuts found")
                .font(.system(size: 15))
                .foregroundStyle(textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Shortcut Explorer Card

struct ShortcutExplorerCard: View {
    let shortcut: Shortcut
    let bgPrimary: Color
    let bgSecondary: Color
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentColor: Color
    

    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            iconView
                .font(.system(size: 18))
                .frame(width: 24)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.action.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(textPrimary)
                
                // Tags (Optional here since we are in a tag view, but good for context)
                if !shortcut.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(shortcut.tags, id: \.self) { tag in
                            Text("#" + tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(textSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            

            
            // Actions (Only visible on hover) removed in favor of Detail View
            
            // Key Combo Badge
            HStack(spacing: 4) { // Spacing 4 like WikiView
                 ForEach(Array(shortcut.keyCombo.keyStrings.enumerated()), id: \.offset) { index, key in
                     if index > 0 {
                         Text("+")
                             .font(.caption)
                             .foregroundStyle(textSecondary)
                     }
                     
                     Text(key)
                         .font(.system(size: 13, weight: .bold, design: .rounded)) // Size 13
                         .foregroundStyle(accentColor) // Orange
                         .padding(.horizontal, 10)
                         .padding(.vertical, 6)
                         .background(accentColor.opacity(0.1))
                         .clipShape(RoundedRectangle(cornerRadius: 6))
                         .overlay(
                             RoundedRectangle(cornerRadius: 6)
                                 .stroke(accentColor.opacity(0.2), lineWidth: 1)
                         )
                 }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? bgSecondary : bgPrimary) // Subtle highlight or white
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(bgTertiary, lineWidth: 1) // Outline for definition
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
}

struct CompactShortcutCard: View {
    let shortcut: Shortcut
    let bgPrimary: Color
    let bgSecondary: Color
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentColor: Color
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            iconView
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
                .background(bgPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            
            // Name
            Text(shortcut.action.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32, alignment: .top)
            
            // Keys
            HStack(spacing: 3) {
                ForEach(Array(shortcut.keyCombo.keyStrings.enumerated()), id: \.offset) { index, key in
                    if index > 0 {
                        Text("+")
                            .font(.system(size: 10))
                            .foregroundStyle(textSecondary)
                    }
                    Text(key)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding(16)
        .frame(minHeight: 130) // Fixed height for consistency
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isHovered ? bgSecondary : bgPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(bgTertiary, lineWidth: 1)
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
}
