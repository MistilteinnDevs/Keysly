import SwiftUI

struct OnboardingView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            headerSection
            
            // Permission steps
            permissionSteps
            
            // Continue button
            if appState.permissionManager.isFullyReady {
                Button("Get Started") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(40)
        .frame(width: 500)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "keyboard.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            
            Text("Welcome to Keysly")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Create shortcuts by pressing keys. Learn them by using them.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Permission Steps
    
    private var permissionSteps: some View {
        VStack(spacing: 16) {
            permissionRow(
                title: "Accessibility Access",
                description: "Required to capture global keyboard shortcuts",
                status: appState.permissionManager.accessibilityStatus,
                action: {
                    appState.permissionManager.openAccessibilitySettings()
                }
            )
        }
    }
    
    private func permissionRow(
        title: String,
        description: String,
        status: PermissionStatus,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 16) {
            // Status icon
            statusIcon(for: status)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Action button
            if status != .granted {
                Button(status == .waiting ? "Waiting..." : "Grant Access") {
                    action()
                }
                .buttonStyle(.bordered)
                .disabled(status == .waiting)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(16)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func statusIcon(for status: PermissionStatus) -> some View {
        Group {
            switch status {
            case .unknown:
                ProgressView()
            case .notGranted:
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            case .waiting:
                ProgressView()
            case .granted:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .font(.title)
        .frame(width: 32)
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
