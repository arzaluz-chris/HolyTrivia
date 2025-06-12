// Presentation/Screens/Quiz/Components/QuestionCard.swift

import SwiftUI

struct QuestionCard: View {
    let question: Question
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.medium) {
            Text(question.text)
                .font(theme.typography.title3)
                .foregroundColor(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let reference = question.bibleReference {
                Text(reference)
                    .font(theme.typography.footnote)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.xLarge)
        .cardStyle()
    }
}
