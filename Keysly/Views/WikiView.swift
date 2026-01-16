import SwiftUI

struct WikiView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ShortcutCategory = .common
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            Divider()
            
            // Content
            HStack(spacing: 0) {
                // Sidebar
                categorySidebar
                    .frame(width: 160)
                
                Divider()
                
                // Shortcuts list
                shortcutsList
            }
        }
        .frame(width: 700, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.title3)
                .foregroundStyle(.purple)
            
            Text("macOS Shortcuts Wiki")
                .font(.headline)
            
            Spacer()
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search shortcuts...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .frame(width: 200)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    // MARK: - Sidebar
    
    private var categorySidebar: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(ShortcutCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack {
                            Image(systemName: category.icon)
                                .frame(width: 20)
                                .foregroundStyle(selectedCategory == category ? .white : .secondary)
                            Text(category.title)
                                .font(.callout)
                                .foregroundStyle(selectedCategory == category ? .white : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? .blue : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
        }
    }
    
    // MARK: - Shortcuts List
    
    private var shortcutsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // Category header
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedCategory.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(selectedCategory.description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
                
                // Shortcuts
                ForEach(filteredShortcuts, id: \.keys) { shortcut in
                    shortcutRow(shortcut)
                }
            }
            .padding(20)
        }
    }
    
    private var filteredShortcuts: [WikiShortcut] {
        let categoryShortcuts = WikiData.shortcuts(for: selectedCategory)
        if searchText.isEmpty {
            return categoryShortcuts
        }
        return categoryShortcuts.filter {
            $0.keys.localizedCaseInsensitiveContains(searchText) ||
            $0.action.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func shortcutRow(_ shortcut: WikiShortcut) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Keys - use indices to avoid duplicate ID warning
            HStack(spacing: 3) {
                ForEach(Array(shortcut.keyParts.enumerated()), id: \.offset) { index, part in
                    if part == "+" {
                        Text("+")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text(part)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(.purple.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .frame(minWidth: 140, alignment: .leading)
            
            // Description
            Text(shortcut.action)
                .font(.callout)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models

enum ShortcutCategory: String, CaseIterable {
    case common
    case copyPaste
    case window
    case navigation
    case screenshot
    case finder
    case documents
    case system
    case special
    
    var title: String {
        switch self {
        case .common: return "Common"
        case .copyPaste: return "Copy & Paste"
        case .window: return "Windows"
        case .navigation: return "Navigation"
        case .screenshot: return "Screenshots"
        case .finder: return "Finder"
        case .documents: return "Documents"
        case .system: return "System"
        case .special: return "Special Characters"
        }
    }
    
    var icon: String {
        switch self {
        case .common: return "star.fill"
        case .copyPaste: return "doc.on.doc"
        case .window: return "macwindow"
        case .navigation: return "arrow.left.arrow.right"
        case .screenshot: return "camera.viewfinder"
        case .finder: return "folder"
        case .documents: return "doc.text"
        case .system: return "gearshape"
        case .special: return "character.textbox"
        }
    }
    
    var description: String {
        switch self {
        case .common: return "Frequently used shortcuts that work across most apps"
        case .copyPaste: return "Cut, copy, paste, and clipboard operations"
        case .window: return "Managing windows and switching between apps"
        case .navigation: return "Moving around in documents and text"
        case .screenshot: return "Capture your screen in various ways"
        case .finder: return "File management and Finder navigation"
        case .documents: return "Text editing and document operations"
        case .system: return "System controls, sleep, and power options"
        case .special: return "Type special characters and symbols"
        }
    }
}

struct WikiShortcut {
    let keys: String
    let action: String
    
    var keyParts: [String] {
        keys.components(separatedBy: " ")
            .flatMap { part -> [String] in
                if part == "+" { return ["+"] }
                return [part, "+"]
            }
            .dropLast()
            .map { String($0) }
    }
}

// MARK: - Wiki Data

struct WikiData {
    static func shortcuts(for category: ShortcutCategory) -> [WikiShortcut] {
        switch category {
        case .common:
            return [
                WikiShortcut(keys: "⌘ Space", action: "Spotlight: Show or hide the search field"),
                WikiShortcut(keys: "⌘ F", action: "Find: Open a Find window, or find items in a document"),
                WikiShortcut(keys: "⌘ G", action: "Find Again: Find the next occurrence"),
                WikiShortcut(keys: "⌘ ⇧ G", action: "Find Previous: Find the previous occurrence"),
                WikiShortcut(keys: "⌘ E", action: "Find Selection: Search for the selected text"),
                WikiShortcut(keys: "⌘ N", action: "New: Open a new document or window"),
                WikiShortcut(keys: "⌘ O", action: "Open: Open the selected item or a file dialog"),
                WikiShortcut(keys: "⌘ S", action: "Save the current document"),
                WikiShortcut(keys: "⌘ P", action: "Print the current document"),
                WikiShortcut(keys: "⌘ W", action: "Close the front window"),
                WikiShortcut(keys: "⌘ Q", action: "Quit the app"),
                WikiShortcut(keys: "⌘ ,", action: "Preferences: Open preferences for the app"),
            ]
            
        case .copyPaste:
            return [
                WikiShortcut(keys: "⌘ A", action: "Select All items"),
                WikiShortcut(keys: "⌘ X", action: "Cut: Remove and copy to Clipboard"),
                WikiShortcut(keys: "⌘ C", action: "Copy the selected item to the Clipboard"),
                WikiShortcut(keys: "⌘ V", action: "Paste the contents of the Clipboard"),
                WikiShortcut(keys: "⌘ ⇧ ⌥ V", action: "Paste and Match Style: Paste without formatting"),
                WikiShortcut(keys: "⌘ ⌥ C", action: "Copy Style: Copy the formatting settings"),
                WikiShortcut(keys: "⌘ ⌥ V", action: "Paste Style: Apply the copied style"),
                WikiShortcut(keys: "⌘ Z", action: "Undo the previous command"),
                WikiShortcut(keys: "⌘ ⇧ Z", action: "Redo: Reverse the undo command"),
            ]
            
        case .window:
            return [
                WikiShortcut(keys: "⌘ Tab", action: "Switch apps: Switch to the next most recently used app"),
                WikiShortcut(keys: "⌘ `", action: "Switch windows: Switch between windows of the front app"),
                WikiShortcut(keys: "⌘ ⇧ `", action: "Switch windows (reverse direction)"),
                WikiShortcut(keys: "⌘ H", action: "Hide the windows of the front app"),
                WikiShortcut(keys: "⌘ ⌥ H", action: "Hide all other apps"),
                WikiShortcut(keys: "⌘ M", action: "Minimize the front window to the Dock"),
                WikiShortcut(keys: "⌘ ⌥ M", action: "Minimize all windows of the front app"),
                WikiShortcut(keys: "⌘ W", action: "Close the front window"),
                WikiShortcut(keys: "⌘ ⌥ W", action: "Close all windows of the app"),
                WikiShortcut(keys: "⌘ ⌥ Esc", action: "Force Quit: Choose an app to force quit"),
            ]
            
        case .navigation:
            return [
                WikiShortcut(keys: "⌃ A", action: "Move to the beginning of the line"),
                WikiShortcut(keys: "⌃ E", action: "Move to the end of a line"),
                WikiShortcut(keys: "⌃ F", action: "Move one character forward"),
                WikiShortcut(keys: "⌃ B", action: "Move one character backward"),
                WikiShortcut(keys: "⌃ P", action: "Move up one line"),
                WikiShortcut(keys: "⌃ N", action: "Move down one line"),
                WikiShortcut(keys: "⌘ ↑", action: "Move to the beginning of the document"),
                WikiShortcut(keys: "⌘ ↓", action: "Move to the end of the document"),
                WikiShortcut(keys: "⌘ ←", action: "Move to the beginning of the current line"),
                WikiShortcut(keys: "⌘ →", action: "Move to the end of the current line"),
                WikiShortcut(keys: "⌥ ←", action: "Move to the beginning of the previous word"),
                WikiShortcut(keys: "⌥ →", action: "Move to the end of the next word"),
                WikiShortcut(keys: "Fn ↑", action: "Page Up: Scroll up one page"),
                WikiShortcut(keys: "Fn ↓", action: "Page Down: Scroll down one page"),
            ]
            
        case .screenshot:
            return [
                WikiShortcut(keys: "⌘ ⇧ 3", action: "Screenshot of the entire screen"),
                WikiShortcut(keys: "⌘ ⇧ 4", action: "Screenshot of selection of screen"),
                WikiShortcut(keys: "⌘ ⇧ 4 Space", action: "Screenshot of a window"),
                WikiShortcut(keys: "⌘ ⇧ 5", action: "Open Screenshot app with options"),
                WikiShortcut(keys: "⌘ ⇧ ⌃ 3", action: "Copy screenshot to clipboard"),
                WikiShortcut(keys: "⌘ ⇧ ⌃ 4", action: "Copy selection screenshot to clipboard"),
            ]
            
        case .finder:
            return [
                WikiShortcut(keys: "⌘ N", action: "Open a new Finder window"),
                WikiShortcut(keys: "⌘ I", action: "Show the Get Info window for a selected file"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "Create a new folder"),
                WikiShortcut(keys: "⌘ ⌫", action: "Move the selected item to the Trash"),
                WikiShortcut(keys: "⌘ ⇧ ⌫", action: "Empty the Trash"),
                WikiShortcut(keys: "⌘ D", action: "Duplicate the selected files"),
                WikiShortcut(keys: "⌘ ⇧ C", action: "Open the Computer window"),
                WikiShortcut(keys: "⌘ ⇧ D", action: "Open the Desktop folder"),
                WikiShortcut(keys: "⌘ ⇧ H", action: "Open the Home folder"),
                WikiShortcut(keys: "⌘ ⇧ G", action: "Open a Go to Folder window"),
                WikiShortcut(keys: "⌘ ⇧ O", action: "Open the Documents folder"),
                WikiShortcut(keys: "⌘ ⌥ L", action: "Open the Downloads folder"),
                WikiShortcut(keys: "⌘ ⇧ U", action: "Open the Utilities folder"),
                WikiShortcut(keys: "⌘ ⇧ R", action: "Open the AirDrop window"),
                WikiShortcut(keys: "Space", action: "Quick Look: Preview the selected item"),
                WikiShortcut(keys: "⌘ 1", action: "View as icons"),
                WikiShortcut(keys: "⌘ 2", action: "View as list"),
                WikiShortcut(keys: "⌘ 3", action: "View as columns"),
                WikiShortcut(keys: "⌘ 4", action: "View as gallery"),
            ]
            
        case .documents:
            return [
                WikiShortcut(keys: "⌘ B", action: "Bold the selected text"),
                WikiShortcut(keys: "⌘ I", action: "Italicize the selected text"),
                WikiShortcut(keys: "⌘ U", action: "Underline the selected text"),
                WikiShortcut(keys: "⌘ T", action: "Show or hide the Fonts window"),
                WikiShortcut(keys: "⌘ ⌃ D", action: "Show definition of the selected word"),
                WikiShortcut(keys: "⌘ ⇧ :", action: "Display Spelling and Grammar window"),
                WikiShortcut(keys: "⌘ ;", action: "Find misspelled words"),
                WikiShortcut(keys: "⌘ {", action: "Left align"),
                WikiShortcut(keys: "⌘ }", action: "Right align"),
                WikiShortcut(keys: "⌘ ⇧ |", action: "Center align"),
                WikiShortcut(keys: "⌃ H", action: "Delete character to the left"),
                WikiShortcut(keys: "⌃ D", action: "Delete character to the right"),
                WikiShortcut(keys: "⌃ K", action: "Delete to the end of the line"),
                WikiShortcut(keys: "⌥ ⌫", action: "Delete the word to the left"),
            ]
            
        case .system:
            return [
                WikiShortcut(keys: "⌘ ⇧ Q", action: "Log out of user account (with confirmation)"),
                WikiShortcut(keys: "⌘ ⌃ Q", action: "Lock screen immediately"),
                WikiShortcut(keys: "⌃ ⌘ ⌽", action: "Force restart"),
                WikiShortcut(keys: "⇧ ⌃ ⌽", action: "Put displays to sleep"),
                WikiShortcut(keys: "⌘ ⌃ ⌽", action: "Quit all apps, then restart"),
                WikiShortcut(keys: "⌘ ⌥ ⌃ ⌽", action: "Quit all apps, then shut down"),
                WikiShortcut(keys: "⌘ ⌃ Space", action: "Emoji & special character picker"),
                WikiShortcut(keys: "⌃ ⌥ Space", action: "Switch input source/keyboard"),
                WikiShortcut(keys: "Fn Fn", action: "Start voice dictation"),
            ]
            
        case .special:
            return [
                WikiShortcut(keys: "⇧ ⌥ -", action: "Em dash (—)"),
                WikiShortcut(keys: "⌥ -", action: "En dash (–)"),
                WikiShortcut(keys: "⌥ ;", action: "Ellipsis (…)"),
                WikiShortcut(keys: "⌥ [", action: "Opening double quote \\u{201C}"),
                WikiShortcut(keys: "⇧ ⌥ [", action: "Closing double quote \\u{201D}"),
                WikiShortcut(keys: "⌥ ]", action: "Opening single quote \\u{2018}"),
                WikiShortcut(keys: "⇧ ⌥ ]", action: "Closing single quote \\u{2019}"),
                WikiShortcut(keys: "⌥ G", action: "Copyright symbol (©)"),
                WikiShortcut(keys: "⌥ R", action: "Registered trademark (®)"),
                WikiShortcut(keys: "⌥ 2", action: "Trademark symbol (™)"),
                WikiShortcut(keys: "⇧ ⌥ 2", action: "Euro sign (€)"),
                WikiShortcut(keys: "⌥ 4", action: "Cent sign (¢)"),
                WikiShortcut(keys: "⌥ 3", action: "Pound sign (£)"),
                WikiShortcut(keys: "⌥ Y", action: "Yen sign (¥)"),
                WikiShortcut(keys: "⌥ 8", action: "Bullet (•)"),
                WikiShortcut(keys: "⇧ ⌥ 8", action: "Degree symbol (°)"),
                WikiShortcut(keys: "⌥ S", action: "German sharp S (ß)"),
            ]
        }
    }
}

#Preview {
    WikiView()
}
