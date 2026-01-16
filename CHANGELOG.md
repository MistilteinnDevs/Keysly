# Changelog

## [v0.1.0] - Pre-Alpha - 2026-01-16

### 🎨 UI & Design Overhaul
- **Theme**: Completely switched from "Dark Minimalist" to a clean **White & Orange** aesthetic.
- **Window**: Increased default application window size to **1000x700** for better content visibility.
- **Sidebar**: Restored text labels for all navigation items for better accessibility.

### ⚡️ Features & Improvements

#### Assignment Prompt (Action Editor)
- **Central Design**: Replaced the segmented control with a large, 5-column **Command Grid** (App, URL, Script, System, Shortcut).
- **Integrated Cards**: configuration inputs (URL, Script) now flow seamlessly with the main view.
- **Inline Selection**: "System Actions" and "Shortcuts" are now selected via a visual card grid instead of dropdowns.
- **In-Window Integration**: The prompt now opens within the main content area rather than as a detached overlay.

#### Wiki
- **Content Expansion**: Added over **100+ macOS shortcuts**, categorized by function (Finder, System, Navigation, Input).
- **Layout**: Moved the search bar to the sidebar for a cleaner reading experience.
- **Typography**: Improved text contrast (Black/Dark Grey) and header sizing.

#### Settings
- **Minimalist Layout**: Removed card containers for a cleaner, flat look.
- **Branding**: Added project attribution ("Open source project by MISTILTEINN") and links to Website/GitHub in the footer.
- **About Section**: Added version info and visual app icon header.

#### System Actions
- **Bug Fix**: Fixed `(-600) Application isn't running` error for the **Empty Trash** action.
  - *Technical Detail*: Switched AppleScript commands to use strict **Bundle IDs** (`com.apple.finder`, `com.apple.systemevents`) instead of app names for better reliability.

### 🛠️ Codebase
- **Refactor**: Cleaned up `AssignmentPromptView` and `SettingsView` code.
- **Shortcuts Support**: Added full support for listing and running Apple Shortcuts via `ShortcutsService`.
