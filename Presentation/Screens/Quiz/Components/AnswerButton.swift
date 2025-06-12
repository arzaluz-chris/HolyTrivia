// Presentation/Screens/Quiz/Components/AnswerButton.swift

import SwiftUI

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @Environment(\.appTheme) private var theme
    @State private var isPressed = false
    
    var backgroundColor: Color {
        if isCorrect {
            return theme.colors.success
        } else if isWrong {
            return theme.colors.error
        } else if isSelected {
            return theme.colors.primary.opacity(0.1)
        } else {
            return Color.white
        }
    }
    
    var textColor: Color {
        if isCorrect || isWrong {
            return .white
        } else {
            return theme.colors.textPrimary
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(theme.typography.body)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(theme.spacing.medium)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(theme.cornerRadius.large)
            .shadow(
                color: theme.shadow.small.color,
                radius: theme.shadow.small.radius,
                x: 0,
                y: theme.shadow.small.y
            )
        }
        .disabled(isDisabled)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(theme.animation.quick, value: isPressed)
        .animation(theme.animation.standard, value: isCorrect)
        .animation(theme.animation.standard, value: isWrong)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { _ in
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}
