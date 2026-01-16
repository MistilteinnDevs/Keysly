import SwiftUI

struct SettingsView: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        TabView {
            // Shortcuts tab
            ShortcutsListView()
                .environment(appState)
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
            
            // Permissions tab
            OnboardingView()
                .environment(appState)
                .tabItem {
                    Label("Permissions", systemImage: "lock.shield")
                }
            
            // About tab
            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 600, height: 450)
    }
    
    // MARK: - About Tab
    
    private var aboutTab: some View {
        VStack(spacing: 24) {
            Image(systemName: "keyboard.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            
            VStack(spacing: 8) {
                Text("Keysly")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 1.0")
                    .foregroundStyle(.secondary)
            }
            
            Text("Press first. Decide later. Learn forever.")
                .font(.title3)
                .italic()
                .foregroundStyle(.secondary)
            
            Divider()
                .frame(width: 200)
            
            VStack(spacing: 4) {
                Text("Self-discoverable shortcuts for macOS")
                    .font(.callout)
                
                Button("View on GitHub") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
