// Core/Theme/AppColors.swift

import SwiftUI

extension AppTheme.Colors {
    // MARK: - Gradient Definitions
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primary, primary.darker(by: 0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var goldGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [gold, gold.darker(by: 0.15)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var successGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [success, success.darker(by: 0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Additional UI Colors
    static var cardBackground: Color {
        Color("White")
    }
    
    static var divider: Color {
        Color.adaptive(
            light: Color(hex: "E5E5EA"),
            dark: Color(hex: "3C3C43")
        )
    }
    
    static var disabled: Color {
        grayLight.opacity(0.6)
    }
    
    // MARK: - Category Color Helpers
    static func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .oldTestament:
            return Color("OldTestamentColor")
        case .newTestament:
            return Color("NewTestamentColor")
        case .gospels:
            return Color("GospelsColor")
        case .characters:
            return Color("CharactersColor")
        case .wisdomProphecy:
            return Color("WisdomColor")
        }
    }
    
    // MARK: - Semantic Color Helpers
    static func feedbackColor(isCorrect: Bool) -> Color {
        isCorrect ? success : error
    }
    
    static func timerColor(for timeRemaining: TimeInterval) -> Color {
        if timeRemaining <= 5 {
            return error
        } else if timeRemaining <= 10 {
            return warning
        } else {
            return primary
        }
    }
}
