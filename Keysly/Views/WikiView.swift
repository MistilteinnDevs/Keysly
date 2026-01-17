import SwiftUI

struct WikiContentView: View {
    let bgPrimary: Color
    let bgSecondary: Color
    let bgTertiary: Color
    let accentColor: Color
    let textPrimary: Color
    let textSecondary: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
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
                .background(bgPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
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
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
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
    case mail, safari, notes, calendar, messages, terminal, preview
    case contacts, reminders, photos, maps, music, news, keynote, numbers, pages
    
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
        case .mail: return "Mail"
        case .safari: return "Safari"
        case .notes: return "Notes"
        case .calendar: return "Calendar"
        case .messages: return "Messages"
        case .terminal: return "Terminal"
        case .preview: return "Preview"
        case .contacts: return "Contacts"
        case .reminders: return "Reminders"
        case .photos: return "Photos"
        case .maps: return "Maps"
        case .music: return "Music"
        case .news: return "News"
        case .keynote: return "Keynote"
        case .numbers: return "Numbers"
        case .pages: return "Pages"
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
        case .mail: return "envelope"
        case .safari: return "safari"
        case .notes: return "note.text"
        case .calendar: return "calendar"
        case .messages: return "message"
        case .terminal: return "apple.terminal"
        case .preview: return "eye"
        case .contacts: return "person.crop.circle"
        case .reminders: return "list.bullet.rectangle"
        case .photos: return "photo"
        case .maps: return "map"
        case .music: return "music.note"
        case .news: return "newspaper"
        case .keynote: return "chart.bar.doc.horizontal" // Approximation
        case .numbers: return "chart.bar"
        case .pages: return "doc.text"
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
        case .mail: return "Inbox navigation, composing, and managing emails."
        case .safari: return "Tabs, browsing history, and page navigation."
        case .notes: return "Formatting, checklists, and note management."
        case .calendar: return "Views, event creation, and navigation."
        case .messages: return "Conversations, replies, and text formatting."
        case .terminal: return "Shell commands, tabs, and window management."
        case .preview: return "Image editing, PDF navigation, and zoom."
        case .contacts: return "Managing contacts, groups, and cards."
        case .reminders: return "Tasks, lists, and due dates."
        case .photos: return "Viewing, editing, and organizing library."
        case .maps: return "Navigation, zoom, and map views."
        case .music: return "Playback control, playlists, and library."
        case .news: return "Reading stories, sidebar, and navigation."
        case .keynote: return "Slides, presentations, and formatting."
        case .numbers: return "Spreadsheets, formulas, and cells."
        case .pages: return "Word processing, layout, and formatting."
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
        // Check new app categories first
        let appSpecific = appShortcuts(for: category)
        if !appSpecific.isEmpty { return appSpecific }
        
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
                WikiShortcut(keys: "⌘ T", action: "Show/Hide Tab Bar"),
                WikiShortcut(keys: "⌘ I", action: "Get Info"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "New folder"),
                WikiShortcut(keys: "⌘ ⌫", action: "Move to Trash"),
                WikiShortcut(keys: "⌘ ⇧ ⌫", action: "Empty Trash"),
                WikiShortcut(keys: "⌘ D", action: "Duplicate"),
                WikiShortcut(keys: "Space", action: "Quick Look"),
                WikiShortcut(keys: "⌘ 1", action: "Icon view"),
                WikiShortcut(keys: "⌘ 2", action: "List view"),
                WikiShortcut(keys: "⌘ 3", action: "Column view"),
                WikiShortcut(keys: "⌘ 4", action: "Gallery view"),
                WikiShortcut(keys: "⌘ [", action: "Previous folder"),
                WikiShortcut(keys: "⌘ ]", action: "Next folder"),
                WikiShortcut(keys: "⌘ ↑", action: "Enclosing folder"),
                WikiShortcut(keys: "⌘ ⇧ G", action: "Go to Folder"),
                WikiShortcut(keys: "⌘ ⇧ A", action: "Go to Applications"),
                WikiShortcut(keys: "⌘ ⇧ U", action: "Go to Utilities"),
                WikiShortcut(keys: "⌘ ⇧ D", action: "Go to Desktop"),
                WikiShortcut(keys: "⌘ ⌥ D", action: "Show/Hide Dock"),
                WikiShortcut(keys: "⌘ J", action: "Show View Options"),
                WikiShortcut(keys: "⌘ K", action: "Connect to Server"),
            ]
        default:
            return []
        }
    }

    private static func appShortcuts(for category: ShortcutCategory) -> [WikiShortcut] {
        switch category {
        case .mail:
            return [
                WikiShortcut(keys: "⌘ N", action: "New message"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "Get new mail"),
                WikiShortcut(keys: "⌘ ⇧ D", action: "Send message"),
                WikiShortcut(keys: "⌘ R", action: "Reply"),
                WikiShortcut(keys: "⌘ ⇧ R", action: "Reply All"),
                WikiShortcut(keys: "⌘ ⇧ F", action: "Forward"),
                WikiShortcut(keys: "⌘ ⇧ A", action: "Attach files"),
                WikiShortcut(keys: "⌘ ⇧ U", action: "Mark as Read/Unread"),
                WikiShortcut(keys: "⌘ 1", action: "Go to Inbox"),
                WikiShortcut(keys: "⌘ 2", action: "Go to VIPs"),
                WikiShortcut(keys: "⌘ 3", action: "Go to Sent"),
                WikiShortcut(keys: "⌘ 0", action: "Message Viewer"),
                WikiShortcut(keys: "⌘ /", action: "Toggle Sidebar"),
                WikiShortcut(keys: "⌃ ⌘ A", action: "Archive selected"),
                WikiShortcut(keys: "⌃ ⌘ J", action: "Mark as Junk"),
            ]
        case .safari:
            return [
                WikiShortcut(keys: "⌘ T", action: "New tab"),
                WikiShortcut(keys: "⌘ N", action: "New window"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "New private window"),
                WikiShortcut(keys: "⌘ L", action: "Open Location (URL)"),
                WikiShortcut(keys: "⌘ W", action: "Close tab"),
                WikiShortcut(keys: "⌘ ⇧ W", action: "Close window"),
                WikiShortcut(keys: "⌘ Z", action: "Reopen last closed tab"),
                WikiShortcut(keys: "⌘ .", action: "Stop loading"),
                WikiShortcut(keys: "⌘ R", action: "Reload page"),
                WikiShortcut(keys: "⌘ [", action: "Back"),
                WikiShortcut(keys: "⌘ ]", action: "Forward"),
                WikiShortcut(keys: "⌘ D", action: "Add bookmark"),
                WikiShortcut(keys: "⌘ ⇧ L", action: "Show Sidebar"),
                WikiShortcut(keys: "⌃ Tab", action: "Next tab"),
                WikiShortcut(keys: "⌃ ⇧ Tab", action: "Previous tab"),
                WikiShortcut(keys: "⌘ 1", action: "Show Bookmarks"),
                WikiShortcut(keys: "⌘ 2", action: "Show Reading List"),
                WikiShortcut(keys: "⌘ ⇧ \\", action: "Show Tab Overview"),
            ]
        case .notes:
            return [
                WikiShortcut(keys: "⌘ N", action: "New note"),
                WikiShortcut(keys: "⌘ D", action: "Duplicate note"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "New folder"),
                WikiShortcut(keys: "⌘ K", action: "Add link"),
                WikiShortcut(keys: "⌘ ⇧ T", action: "Title format"),
                WikiShortcut(keys: "⌘ ⇧ H", action: "Heading format"),
                WikiShortcut(keys: "⌘ ⇧ J", action: "Subheading format"),
                WikiShortcut(keys: "⌘ ⇧ B", action: "Body format"),
                WikiShortcut(keys: "⌘ ⇧ L", action: "Checklist format"),
                WikiShortcut(keys: "⌘ ⇧ U", action: "Mark checked/unchecked"),
                WikiShortcut(keys: "⌘ +", action: "Increase text size"),
                WikiShortcut(keys: "⌘ -", action: "Decrease text size"),
                WikiShortcut(keys: "⌥ ⌘ F", action: "Search all notes"),
                WikiShortcut(keys: "⌘ 1", action: "List view"),
                WikiShortcut(keys: "⌘ 2", action: "Gallery view"),
                WikiShortcut(keys: "⌘ 3", action: "Show attachments"),
            ]
        case .calendar:
            return [
                WikiShortcut(keys: "⌘ N", action: "New event"),
                WikiShortcut(keys: "⌘ E", action: "Edit event"),
                WikiShortcut(keys: "⌘ T", action: "Go to Today"),
                WikiShortcut(keys: "⌘ ⇧ T", action: "Go to Date"),
                WikiShortcut(keys: "⌘ 1", action: "Day view"),
                WikiShortcut(keys: "⌘ 2", action: "Week view"),
                WikiShortcut(keys: "⌘ 3", action: "Month view"),
                WikiShortcut(keys: "⌘ 4", action: "Year view"),
                WikiShortcut(keys: "⌘ R", action: "Refresh calendars"),
                WikiShortcut(keys: "⌘ ⌥ I", action: "Inspector"),
                WikiShortcut(keys: "⌘ I", action: "Get Info"),
                WikiShortcut(keys: "Space", action: "Select next calendar (List)"),
                WikiShortcut(keys: "⌘ →", action: "Next day/week/month"),
                WikiShortcut(keys: "⌘ ←", action: "Previous day/week/month"),
            ]
        case .messages:
            return [
                WikiShortcut(keys: "⌘ N", action: "New conversation"),
                WikiShortcut(keys: "⌘ R", action: "Reply"),
                WikiShortcut(keys: "⌘ ⇧ U", action: "Mark Unread"),
                WikiShortcut(keys: "⌃ ⌘ 1", action: "All messages"),
                WikiShortcut(keys: "⌃ ⌘ 2", action: "Known senders"),
                WikiShortcut(keys: "⌃ ⌘ 3", action: "Unknown senders"),
                WikiShortcut(keys: "⌃ Tab", action: "Next Conversation"),
                WikiShortcut(keys: "⌘ 0", action: "Messages Window"),
                WikiShortcut(keys: "⌘ E", action: "Edit sent message"),
                WikiShortcut(keys: "⌘ T", action: "Tapback (then 1-6)"),
                WikiShortcut(keys: "Space", action: "Quick Look image"),
            ]
        case .terminal:
            return [
                WikiShortcut(keys: "⌘ N", action: "New window"),
                WikiShortcut(keys: "⌘ T", action: "New tab"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "New Command"),
                WikiShortcut(keys: "⌘ ⇧ K", action: "New Remote Connection"),
                WikiShortcut(keys: "⌘ I", action: "Inspector"),
                WikiShortcut(keys: "⌘ D", action: "Split Pane"),
                WikiShortcut(keys: "⌘ ⇧ D", action: "Close Pane"),
                WikiShortcut(keys: "⌘ W", action: "Close Tab"),
                WikiShortcut(keys: "⌃ A", action: "Start of line"),
                WikiShortcut(keys: "⌃ E", action: "End of line"),
                WikiShortcut(keys: "⌃ U", action: "Delete line"),
                WikiShortcut(keys: "⌃ K", action: "Delete to end"),
                WikiShortcut(keys: "⌘ K", action: "Clear scrollback"),
            ]
        case .preview:
            return [
                WikiShortcut(keys: "⌘ ⇧ +", action: "Zoom In"),
                WikiShortcut(keys: "⌘ ⇧ -", action: "Zoom Out"),
                WikiShortcut(keys: "⌘ 0", action: "Actual Size"),
                WikiShortcut(keys: "⌘ 9", action: "Zoom to Fit"),
                WikiShortcut(keys: "⌘ ⇧ A", action: "Annotate Toolbar"),
                WikiShortcut(keys: "⌘ R", action: "Rotate Left"),
                WikiShortcut(keys: "⌘ L", action: "Rotate Right"),
                WikiShortcut(keys: "⌘ ⇧ T", action: "Show Markup Toolbar"),
                WikiShortcut(keys: "⌘ ⌥ 0", action: "Contact Sheet"),
            ]
        case .contacts:
            return [
                WikiShortcut(keys: "⌘ N", action: "New Contact"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "New List"),
                WikiShortcut(keys: "⌘ S", action: "Save Contact"),
                WikiShortcut(keys: "⌘ L", action: "Edit Contact"),
                WikiShortcut(keys: "⌘ I", action: "View Card"),
                WikiShortcut(keys: "⌘ ]", action: "Next Card"),
                WikiShortcut(keys: "⌘ [", action: "Previous Card"),
                WikiShortcut(keys: "⌘ 1", action: "Show/Hide Groups"),
            ]
        case .reminders:
            return [
                WikiShortcut(keys: "⌘ N", action: "New Reminder"),
                WikiShortcut(keys: "⌘ ⇧ N", action: "New List"),
                WikiShortcut(keys: "⌘ E", action: "Show Subtasks"),
                WikiShortcut(keys: "⌘ T", action: "Due Today"),
                WikiShortcut(keys: "⌥ ⌘ T", action: "Due Tomorrow"),
                WikiShortcut(keys: "⌘ K", action: "Due Weekend"),
                WikiShortcut(keys: "⌘ ⇧ F", action: "Flag"),
                WikiShortcut(keys: "⌘ ⇧ C", action: "Mark Completed"),
            ]
        case .photos:
             return [
                 WikiShortcut(keys: "Space", action: "Open/Close Photo"),
                 WikiShortcut(keys: "Return", action: "Edit Photo"),
                 WikiShortcut(keys: "C", action: "Crop"),
                 WikiShortcut(keys: "A", action: "Adjust"),
                 WikiShortcut(keys: "F", action: "Filters"),
                 WikiShortcut(keys: "⌘ R", action: "Rotate"),
                 WikiShortcut(keys: "⌘ E", action: "Auto-Enhance"),
                 WikiShortcut(keys: "⌘ L", action: "Hide Photo"),
                 WikiShortcut(keys: "⌘ D", action: "Duplicate"),
                 WikiShortcut(keys: "Period", action: "Favorite Matches"),
                 WikiShortcut(keys: "⌃ ⌘ F", action: "Full Screen"),
             ]
        case .maps:
             return [
                 WikiShortcut(keys: "⌘ L", action: "Show Location"),
                 WikiShortcut(keys: "⌘ +", action: "Zoom In"),
                 WikiShortcut(keys: "⌘ -", action: "Zoom Out"),
                 WikiShortcut(keys: "⌘ 1", action: "Explore View"),
                 WikiShortcut(keys: "⌘ 2", action: "Driving View"),
                 WikiShortcut(keys: "⌘ 3", action: "Transit View"),
                 WikiShortcut(keys: "⌘ 4", action: "Satellite View"),
                 WikiShortcut(keys: "⌘ D", action: "Toggle 3D"),
             ]
        case .music:
             return [
                 WikiShortcut(keys: "Space", action: "Play/Pause"),
                 WikiShortcut(keys: "⌘ →", action: "Next Song"),
                 WikiShortcut(keys: "⌘ ←", action: "Previous Song"),
                 WikiShortcut(keys: "⌘ ↑", action: "Volume Up"),
                 WikiShortcut(keys: "⌘ ↓", action: "Volume Down"),
                 WikiShortcut(keys: "⌘ N", action: "New Playlist"),
                 WikiShortcut(keys: "⌥ ⌘ E", action: "Equalizer"),
                 WikiShortcut(keys: "⌥ ⌘ M", action: "Mini Player"),
             ]
        case .news:
             return [
                 WikiShortcut(keys: "⌘ N", action: "New Window"),
                 WikiShortcut(keys: "⌘ R", action: "Refresh Feed"),
                 WikiShortcut(keys: "⌘ S", action: "Save Story"),
                 WikiShortcut(keys: "⌘ L", action: "Suggest More Like This"),
                 WikiShortcut(keys: "⌘ D", action: "Suggest Less Like This"),
                 WikiShortcut(keys: "⌘ →", action: "Next Story"),
                 WikiShortcut(keys: "⌘ ←", action: "Previous Story"),
             ]
        case .keynote:
             return [
                 WikiShortcut(keys: "⌘ N", action: "New Presentation"),
                 WikiShortcut(keys: "⌥ ⌘ P", action: "Play Slideshow"),
                 WikiShortcut(keys: "⌘ ⇧ P", action: "Show Presenter Notes"),
                 WikiShortcut(keys: "⌥ ⌘ G", action: "Group Objects"),
                 WikiShortcut(keys: "⌥ ⇧ ⌘ G", action: "Ungroup Objects"),
                 WikiShortcut(keys: "⌘ L", action: "Lock Object"),
                 WikiShortcut(keys: "⌥ ⌘ L", action: "Unlock Object"),
             ]
        case .numbers:
             return [
                 WikiShortcut(keys: "⌘ N", action: "New Spreadsheet"),
                 WikiShortcut(keys: "⌘ ⇧ N", action: "Add Sheet"),
                 WikiShortcut(keys: "Option ⌘ F", action: "Toggle Filters"),
                 WikiShortcut(keys: "Option ⌘ U", action: "Auto-Align Content"),
                 WikiShortcut(keys: "=", action: "Start Formula"),
             ]
        case .pages:
             return [
                 WikiShortcut(keys: "⌘ N", action: "New Document"),
                 WikiShortcut(keys: "⌘ R", action: "Show Ruler"),
                 WikiShortcut(keys: "⌘ ⇧ W", action: "Word Count"),
                 WikiShortcut(keys: "⌘ ⇧ L", action: "Show Layout"),
                 WikiShortcut(keys: "⌘ Return", action: "Page Break"),
                 WikiShortcut(keys: "⌘ ;", action: "Check Spelling"),
             ]
        default:
            return []
        }
    }
}
