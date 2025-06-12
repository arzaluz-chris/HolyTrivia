// Presentation/Screens/Quiz/Components/TimerView.swift

import SwiftUI

struct TimerView: View {
    let timeRemaining: TimeInterval
    
    var timerColor: Color {
        if timeRemaining <= 5 {
            return AppTheme.Colors.error
        } else if timeRemaining <= 10 {
            return AppTheme.Colors.warning
        } else {
            return AppTheme.Colors.primary
        }
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xxSmall) {
            Image(systemName: "clock.fill")
                .font(.footnote)
            
            Text(String(format: "0:%02d", Int(timeRemaining)))
                .font(AppTheme.Typography.subheadline.monospacedDigit().bold())
        }
        .foregroundColor(timerColor)
        .animation(AppTheme.Animation.quick, value: timerColor)
    }
}
