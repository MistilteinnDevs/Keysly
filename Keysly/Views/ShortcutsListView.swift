import SwiftUI

struct ShortcutsListView: View {
    
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var selectedShortcut: Shortcut?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            Divider()
            
            // Shortcuts list
            if filteredShortcuts.isEmpty {
                emptyState
            } else {
                shortcutsList
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search shortcuts...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(12)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            if searchText.isEmpty {
                Text("No shortcuts yet")
                    .font(.headline)
                Text("Press any key combo anywhere to create your first shortcut.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("No matching shortcuts")
                    .font(.headline)
                Text("Try a different search term.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Shortcuts List
    
    private var shortcutsList: some View {
        List(selection: $selectedShortcut) {
            ForEach(filteredShortcuts) { shortcut in
                shortcutRow(shortcut)
                    .tag(shortcut)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            appState.shortcutStore.deleteShortcut(id: shortcut.id)
                        }
                    }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let shortcut = filteredShortcuts[index]
                    appState.shortcutStore.deleteShortcut(id: shortcut.id)
                }
            }
        }
        .listStyle(.inset)
    }
    
    private func shortcutRow(_ shortcut: Shortcut) -> some View {
        HStack(spacing: 12) {
            // Key combo badge
            Text(shortcut.keyCombo.displayString)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // Action info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: shortcut.action.iconName)
                        .foregroundStyle(.secondary)
                    Text(shortcut.action.displayName)
                }
                
                if let contextApp = shortcut.contextAppBundleId {
                    Text("In: \(contextApp)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("Global")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 2) {
                Text("×\(shortcut.useCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let lastUsed = shortcut.lastUsedAt {
                    Text(lastUsed, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Filtering
    
    private var filteredShortcuts: [Shortcut] {
        appState.shortcutStore.search(query: searchText)
    }
}

#Preview {
    ShortcutsListView()
        .environment(AppState())
        .frame(width: 500, height: 400)
}
