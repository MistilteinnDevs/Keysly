import SwiftUI

struct SettingsView: View {
    
    @Environment(AppState.self) private var appState
    
    // Persistent Settings
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    @AppStorage("playSounds") private var playSounds = true
    @AppStorage("checkForUpdates") private var checkForUpdates = true
    
    // Theme Colors
    private let textPrimary = Color.black
    private let textSecondary = Color.gray
    private let accentColor = Color(hex: 0xFF9500)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Image("app-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keysly")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(textPrimary)
                    
                    Text("Pre-Alpha v0.1")
                        .font(.caption)
                        .foregroundStyle(textSecondary)
                }
                
                Spacer()
            }
            .padding(24)
            .padding(.bottom, 8)
            
            // Settings List
            VStack(spacing: 0) {
                // Permission Row
                Button {
                    appState.permissionManager.openAccessibilitySettings()
                } label: {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(appState.permissionManager.isFullyReady ? .green : .orange)
                            .font(.system(size: 16))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accessibility Access")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(textPrimary)
                            Text(appState.permissionManager.isFullyReady ? "Granted" : "Required for shortcuts")
                                .font(.caption)
                                .foregroundStyle(textSecondary)
                        }
                        
                        Spacer()
                        
                        if !appState.permissionManager.isFullyReady {
                            Text("Fix")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(accentColor))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(12)
                    .background(Color(hex: 0xF5F5F7))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Minimal Footer
            VStack(spacing: 8) {
                Text("Open source project by MISTILTEINN")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(textSecondary)
                
                HStack(spacing: 16) {
                    Link("Website", destination: URL(string: "https://www.mistilteinn.xyz")!)
                    Link("GitHub", destination: URL(string: "https://github.com/PRATIKK0709/Keysly")!)
                }
                .font(.system(size: 11))
                .foregroundStyle(textSecondary)
                .underline()
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}
