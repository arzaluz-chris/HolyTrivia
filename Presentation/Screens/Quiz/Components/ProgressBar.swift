// Presentation/Screens/Quiz/Components/ProgressBar.swift

import SwiftUI

struct ProgressBar: View {
    let current: Int
    let total: Int
    @Environment(\.appTheme) private var theme
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.colors.primary.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.colors.primary)
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(theme.animation.standard, value: progress)
            }
        }
        .frame(height: 8)
    }
}
