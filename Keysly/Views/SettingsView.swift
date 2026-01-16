import SwiftUI

struct SettingsView: View {
    
    @Environment(AppState.self) private var appState
    
    // Theme Colors (Private instances to match main app)
    private let bgPrimary = Color(hex: 0xFFFFFF)
    private let bgSecondary = Color(hex: 0xF5F5F7)
    private let bgTertiary = Color(hex: 0xE5E5EB)
    private let textPrimary = Color(hex: 0x000000)
    private let textSecondary = Color(hex: 0x6E6E73)
    private let accentColor = Color(hex: 0xFF9500)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(textPrimary)
                Spacer()
            }
            .padding(24)
            .background(bgPrimary)
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Permissions Section (Keep this at top)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("System Access")
                            .font(.headline)
                            .foregroundStyle(textPrimary)
                        
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(appState.permissionManager.isFullyReady ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Accessibility Permissions")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(textPrimary)
                                Text(appState.permissionManager.isFullyReady ? "Granted" : "Required for shortcut detection")
                                    .font(.caption)
                                    .foregroundStyle(textSecondary)
                            }
                            
                            Spacer()
                            
                            if !appState.permissionManager.isFullyReady {
                                Button("Open Settings") {
                                    appState.permissionManager.openAccessibilitySettings()
                                }
                                .buttonStyle(.plain)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            }
                        }

                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        
                        Divider()
                            .background(bgTertiary)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Footer Branding (No Card, Bottom)
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "command")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(accentColor)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Keysly")
                                    .font(.headline)
                                    .foregroundStyle(textPrimary)
                                Text("Pre-Alpha v0.1")
                                    .font(.caption)
                                    .foregroundStyle(textSecondary)
                            }
                        }
                        
                        Text("Open source project by MISTILTEINN")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(textSecondary)
                        
                        HStack(spacing: 24) {
                            Link(destination: URL(string: "https://www.mistilteinn.xyz")!) {
                                Text("Website")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(textSecondary)
                                    .underline()
                            }
                            
                            Link(destination: URL(string: "https://github.com/PRATIKK0709/Keysly")!) {
                                Text("GitHub")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(textSecondary)
                                    .underline()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .padding(24)
            }
        }
        .background(bgPrimary)
    }
}
