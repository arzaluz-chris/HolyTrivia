// Presentation/SharedComponents/ErrorView.swift

import SwiftUI

struct ErrorView: View {
    let error: Error
    let retry: () -> Void
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.colors.error)
            
            VStack(spacing: theme.spacing.small) {
                Text("Something went wrong")
                    .font(theme.typography.title2)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text(error.localizedDescription)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: retry) {
                Text("Try Again")
                    .primaryButton()
            }
            .padding(.horizontal, theme.spacing.xLarge)
        }
        .padding(theme.spacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
    }
}
