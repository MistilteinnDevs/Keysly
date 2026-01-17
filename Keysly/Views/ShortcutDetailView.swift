import SwiftUI

struct ShortcutDetailView: View {
    let shortcut: Shortcut
    let onClose: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    // Theme Colors
    private let bgSecondary = Color(hex: 0xF5F5F7)
    private let accentColor = Color(hex: 0xFF9500)
    private let textPrimary = Color(hex: 0x000000)
    private let textSecondary = Color(hex: 0x6E6E73)
    private let deleteColor = Color(hex: 0xFF3B30)
    
    var body: some View {
        VStack(spacing: 24) {
            // Close Button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(textSecondary.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            
            // Icon
            iconView
                .font(.system(size: 48))
                .frame(width: 80, height: 80)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
            
            // Info
            VStack(spacing: 8) {
                Text(shortcut.action.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(textPrimary)
                    .multilineTextAlignment(.center)
                
                if !shortcut.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(shortcut.tags, id: \.self) { tag in
                            Text("#" + tag)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(bgSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // Key Combo Display (Large)
            HStack(spacing: 4) {
                ForEach(Array(shortcut.keyCombo.keyStrings.enumerated()), id: \.offset) { index, key in
                    if index > 0 {
                        Text("+")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(textSecondary)
                    }
                    
                    Text(key)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                             RoundedRectangle(cornerRadius: 10)
                                 .stroke(accentColor.opacity(0.2), lineWidth: 1)
                         )
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                Button(action: {
                    onDelete()
                }) {
                    Text("Delete")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(deleteColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(deleteColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .frame(width: 100)
                
                Button(action: {
                    onEdit()
                }) {
                    Text("Edit Shortcut")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: accentColor.opacity(0.3), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(width: 400, height: 480)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 10)
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch shortcut.action {
        case .launchApp(let bundleId, _):
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
            } else {
                Image(systemName: "app.fill")
                    .foregroundStyle(textSecondary)
            }
        case .runShortcut:
            Image(systemName: "bolt.fill")
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
