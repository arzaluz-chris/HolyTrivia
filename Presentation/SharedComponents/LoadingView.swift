// Presentation/SharedComponents/LoadingView.swift

import SwiftUI

struct LoadingView: View {
    @Environment(\.appTheme) private var theme
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: theme.spacing.medium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.primary))
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(theme.typography.subheadline)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
    }
}
