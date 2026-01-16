import SwiftUI

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
            VStack(spacing: 0) {
                // Search in Sidebar
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
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .padding(12)
                
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(ShortcutCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 14))
                                        .frame(width: 20)
                                        .foregroundStyle(selectedCategory == category ? .white : textPrimary)
                                    Text(category.title)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(selectedCategory == category ? .white : textPrimary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? accentColor : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
            .frame(width: 220) // Slightly wider for search bar
            .background(bgSecondary.opacity(0.5))
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.05))
                    .frame(width: 1),
                alignment: .trailing
            )
            
            // Content
            VStack(spacing: 0) {
                // Toolbar (Just Title now)
                HStack {
                    Text(selectedCategory.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(textPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                .padding(.bottom, 24)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        Text(selectedCategory.description)
                            .font(.system(size: 16))
                            .foregroundStyle(textSecondary)
                            .padding(.bottom, 24)
                        
                        ForEach(filteredShortcuts, id: \.keys) { shortcut in
                            WikiShortcutRow(
                                shortcut: shortcut,
                                bgTertiary: bgTertiary,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                accentColor: accentColor
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
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
}

struct WikiShortcutRow: View {
    let shortcut: WikiShortcut
    let bgTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let accentColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            // Keys
            HStack(spacing: 4) {
                ForEach(Array(shortcut.keyParts.enumerated()), id: \.offset) { _, part in
                    if part == "+" {
                        Text("+")
                            .font(.caption)
                            .foregroundStyle(textSecondary)
                    } else {
                        Text(part)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(accentColor)
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
            .frame(minWidth: 160, alignment: .leading) // More breathing room for keys
            
            Text(shortcut.action)
                .font(.system(size: 15)) // Larger font
                .foregroundStyle(textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
            
            Spacer()
        }
        .padding(16) // Increased padding
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(bgTertiary.opacity(0.5))
        )
    }
}

// MARK: - Data Models

enum ShortcutCategory: String, CaseIterable {
    case common, copyPaste, window, app, navigation, screenshot, finder, documents, system, input
    
    var title: String {
        switch self {
        case .common: return "Common & Search"
        case .copyPaste: return "Copy & Paste"
        case .window: return "Windows"
        case .app: return "Applications"
        case .navigation: return "Navigation"
        case .screenshot: return "Screenshots"
        case .finder: return "Finder"
        case .documents: return "Documents"
        case .system: return "System & Power"
        case .input: return "Input & Special"
        }
    }
    
    var icon: String {
        switch self {
        case .common: return "star"
        case .copyPaste: return "doc.on.doc"
        case .window: return "macwindow"
        case .app: return "app.dashed"
        case .navigation: return "arrow.up.left.and.arrow.down.right"
        case .screenshot: return "camera.viewfinder"
        case .finder: return "folder"
        case .documents: return "doc.text"
        case .system: return "power"
        case .input: return "keyboard"
        }
    }
    
    var description: String {
        switch self {
        case .common: return "Essential searching and common operations."
        case .copyPaste: return "Clipboard, undo/redo, and style matching."
        case .window: return "Switching, minimizing, and hiding windows."
        case .app: return "Quit, force quit, and app preferences."
        case .navigation: return "Moving cursor and scrolling pages."
        case .screenshot: return "Capturing screens, windows, and recordings."
        case .finder: return "File management and Finder navigation."
        case .documents: return "Text manipulation, alignment, and editing."
        case .system: return "Sleep, restart, logout, and power options."
        case .input: return "Accents, emoji, and special characters."
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

struct WikiData {
    static func shortcuts(for category: ShortcutCategory) -> [WikiShortcut] {
        switch category {
        case .common:
            return [
                WikiShortcut(keys: "⌘ F", action: "Find: Open a Find window, or find items in a document"),
                WikiShortcut(keys: "⌘ G", action: "Find Again: Find the next occurrence"),
                WikiShortcut(keys: "⌘ ⇧ G", action: "Find Previous: Find the previous occurrence"),
                WikiShortcut(keys: "⌘ E", action: "Find Selection: Search for the selected text"),
                WikiShortcut(keys: "⌘ Space", action: "Spotlight: Show or hide the Spotlight search field"),
                WikiShortcut(keys: "⌥ Space", action: "Show Finder search window"),
            ]
        case .copyPaste:
            return [
                WikiShortcut(keys: "⌘ A", action: "Select All items"),
                WikiShortcut(keys: "⌘ X", action: "Cut: Remove and copy to Clipboard"),
                WikiShortcut(keys: "⌘ C", action: "Copy the selected item to the Clipboard"),
                WikiShortcut(keys: "⌘ V", action: "Paste the contents of the Clipboard"),
                WikiShortcut(keys: "⌘ ⇧ ⌥ V", action: "Paste and Match Style: Paste without formatting"),
                WikiShortcut(keys: "⌘ ⌥ C", action: "Copy Style: Copy formatting settings"),
                WikiShortcut(keys: "⌘ ⌥ V", action: "Paste Style: Apply copied style"),
                WikiShortcut(keys: "⌘ Z", action: "Undo the previous command"),
                WikiShortcut(keys: "⌘ ⇧ Z", action: "Redo: Reverse the undo command"),
            ]
        case .window:
            return [
                WikiShortcut(keys: "⌘ Tab", action: "Switch apps: Next most recently used app"),
                WikiShortcut(keys: "⌘ `", action: "Switch windows: Next window of front app"),
                WikiShortcut(keys: "⌘ ⇧ `", action: "Switch windows (reverse direction)"),
                WikiShortcut(keys: "⌘ H", action: "Hide the windows of the front app"),
                WikiShortcut(keys: "⌘ ⌥ H", action: "Hide all other apps"),
                WikiShortcut(keys: "⌘ M", action: "Minimize the front window to the Dock"),
                WikiShortcut(keys: "⌘ ⌥ M", action: "Minimize all windows of the front app"),
                WikiShortcut(keys: "⌘ W", action: "Close the front window"),
                WikiShortcut(keys: "⌘ ⌥ W", action: "Close all windows of the app"),
                WikiShortcut(keys: "⌃ F4", action: "Change focus to active or next window"),
            ]
        case .app:
            return [
                WikiShortcut(keys: "⌘ N", action: "New: Open a new document or window"),
                WikiShortcut(keys: "⌘ O", action: "Open: Open the selected item or dialog"),
                WikiShortcut(keys: "⌘ S", action: "Save the current document"),
                WikiShortcut(keys: "⌘ P", action: "Print the current document"),
                WikiShortcut(keys: "⌘ Q", action: "Quit the app"),
                WikiShortcut(keys: "⌘ ⌥ Esc", action: "Force Quit: Choose an app to force quit"),
                WikiShortcut(keys: "⌘ ,", action: "Preferences: Open app preferences"),
                WikiShortcut(keys: "⌘ ⇧ ?", action: "Open the Help menu"),
                WikiShortcut(keys: "⌘ ⌥ T", action: "Show or hide a toolbar"),
            ]
        case .input:
            return [
                WikiShortcut(keys: "⌃ ⌘ Space", action: "Emoji and special character picker"),
                WikiShortcut(keys: "Fn Fn", action: "Start voice dictation"),
                WikiShortcut(keys: "⇧ ⌥ -", action: "Em dash (—)"),
                WikiShortcut(keys: "⌥ -", action: "En dash (–)"),
                WikiShortcut(keys: "⌥ ;", action: "Ellipsis (…)"),
                WikiShortcut(keys: "⌥ [", action: "Opening double quote “"),
                WikiShortcut(keys: "⇧ ⌥ [", action: "Closing double quote ”"),
                WikiShortcut(keys: "⌥ G", action: "Copyright ©"),
                WikiShortcut(keys: "⌥ R", action: "Registered ®"),
                WikiShortcut(keys: "⌥ 2", action: "Trademark ™"),
                WikiShortcut(keys: "⇧ ⌥ 2", action: "Euro €"),
                WikiShortcut(keys: "⌥ E", action: "Acute accent (e.g. ´)"),
                WikiShortcut(keys: "⌥ I", action: "Circumflex accent (e.g. ˆ)"),
                WikiShortcut(keys: "⌥ U", action: "Umlaut accent (e.g. ¨)"),
            ]
        case .navigation:
             return [
                 WikiShortcut(keys: "Fn ↑", action: "Page Up: Scroll up one page"),
                 WikiShortcut(keys: "Fn ↓", action: "Page Down: Scroll down one page"),
                 WikiShortcut(keys: "Fn ←", action: "Home: Scroll to beginning"),
                 WikiShortcut(keys: "Fn →", action: "End: Scroll to end"),
                 WikiShortcut(keys: "⌘ ↑", action: "Move to beginning of document"),
                 WikiShortcut(keys: "⌘ ↓", action: "Move to end of document"),
                 WikiShortcut(keys: "⌃ A", action: "Move to beginning of line/paragraph"),
                 WikiShortcut(keys: "⌃ E", action: "Move to end of line/paragraph"),
                 WikiShortcut(keys: "⌥ ←", action: "Move to beginning of previous word"),
                 WikiShortcut(keys: "⌥ →", action: "Move to end of next word"),
             ]
        case .screenshot:
             return [
                 WikiShortcut(keys: "⌘ ⇧ 3", action: "Screenshot of entire screen"),
                 WikiShortcut(keys: "⌘ ⇧ 4", action: "Screenshot of selection"),
                 WikiShortcut(keys: "⌘ ⇧ 4 Space", action: "Screenshot of window"),
                 WikiShortcut(keys: "⌘ ⇧ 5", action: "Screenshot app / options"),
             ]
        case .system:
             return [
                 WikiShortcut(keys: "⌘ ⇧ Q", action: "Log out (with confirmation)"),
                 WikiShortcut(keys: "⌘ ⇧ ⌥ Q", action: "Log out (no confirmation)"),
                 WikiShortcut(keys: "⌘ ⌃ ⌽", action: "Force restart"),
                 WikiShortcut(keys: "⇧ ⌃ ⌽", action: "Put displays to sleep"),
                 WikiShortcut(keys: "⌘ ⌥ ⌃ ⌽", action: "Quit all apps, then shut down"),
             ]
        case .documents:
             return [
                 WikiShortcut(keys: "⌘ B", action: "Bold selected text"),
                 WikiShortcut(keys: "⌘ I", action: "Italicize selected text"),
                 WikiShortcut(keys: "⌘ U", action: "Underline selected text"),
                 WikiShortcut(keys: "⌘ T", action: "Show/hide Fonts window"),
                 WikiShortcut(keys: "⌘ ⌃ D", action: "Show definition of selected word"),
                 WikiShortcut(keys: "⌘ ⇧ :", action: "Spelling and Grammar window"),
                 WikiShortcut(keys: "⌃ H", action: "Delete character to left"),
                 WikiShortcut(keys: "⌃ D", action: "Delete character to right"),
                 WikiShortcut(keys: "⌃ K", action: "Delete to end of line/paragraph"),
                 WikiShortcut(keys: "⌥ ⌫", action: "Delete word to left"),
             ]
        case .finder:
             return [
                 WikiShortcut(keys: "⌘ N", action: "Open new Finder window"),
                 WikiShortcut(keys: "⌘ I", action: "Get Info for selected file"),
                 WikiShortcut(keys: "⌘ ⇧ N", action: "Create new folder"),
                 WikiShortcut(keys: "⌘ ⌫", action: "Move to Trash"),
                 WikiShortcut(keys: "⌘ ⇧ ⌫", action: "Empty Trash"),
                 WikiShortcut(keys: "⌘ D", action: "Duplicate selected files"),
                 WikiShortcut(keys: "Space", action: "Quick Look"),
                 WikiShortcut(keys: "⌘ 1", action: "View as icons"),
                 WikiShortcut(keys: "⌘ 2", action: "View as list"),
                 WikiShortcut(keys: "⌘ 3", action: "View as columns"),
                 WikiShortcut(keys: "⌘ [", action: "Go to previous folder"),
                 WikiShortcut(keys: "⌘ ]", action: "Go to next folder"),
             ]
        }
    }
}
