// Presentation/SharedComponents/EmptyStateView.swift

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(theme.colors.textSecondary.opacity(0.5))
            
            VStack(spacing: theme.spacing.small) {
                Text(title)
                    .font(theme.typography.title2)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text(message)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .primaryButton()
                }
                .padding(.horizontal, theme.spacing.xLarge)
            }
        }
        .padding(theme.spacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
    }
}
