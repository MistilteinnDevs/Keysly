import SwiftUI

struct KeyCaptureOverlay: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 16) {
            // Keys display
            if let keyCombo = appState.pendingKeyCombo {
                keyDisplay(keyCombo)
            } else {
                Text("Press a key combination...")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(32)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 20)
        }
    }
    
    private func keyDisplay(_ keyCombo: KeyCombo) -> some View {
        HStack(spacing: 8) {
            ForEach(keyCombo.modifiers.symbols.map(String.init), id: \.self) { symbol in
                keyBadge(symbol)
            }
            
            keyBadge(keyCombo.keyString)
        }
    }
    
    private func keyBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .medium, design: .rounded))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            }
    }
}

#Preview {
    KeyCaptureOverlay()
        .environment(AppState())
        .padding(40)
        .background(.gray.opacity(0.2))
}
