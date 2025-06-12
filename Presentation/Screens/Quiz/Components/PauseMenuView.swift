// Presentation/Screens/Quiz/Components/PauseMenuView.swift

import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onQuit: () -> Void
    
    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: theme.spacing.xLarge) {
            // Header
            VStack(spacing: theme.spacing.small) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.colors.primary)
                
                Text("Quiz Paused")
                    .font(theme.typography.title)
            }
            .padding(.top, theme.spacing.xLarge)
            
            // Buttons
            VStack(spacing: theme.spacing.medium) {
                Button(action: onResume) {
                    Label("Resume Quiz", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .primaryButton()
                
                Button(action: onQuit) {
                    Label("Quit Quiz", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .secondaryButton()
            }
            .padding(.horizontal, theme.spacing.large)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
    }
}
