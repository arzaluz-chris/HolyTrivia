// Core/Theme/AppFonts.swift

import SwiftUI

extension AppTheme.Typography {
    // MARK: - Additional Typography Styles
    
    // Quiz specific
    static var quizTimer: Font {
        Font.system(size: 16, weight: .bold, design: .monospaced)
    }
    
    static var quizScore: Font {
        Font.system(size: 20, weight: .bold, design: .rounded)
    }
    
    static var quizProgress: Font {
        Font.system(size: 14, weight: .medium, design: .default)
    }
    
    // Leaderboard specific
    static var leaderboardRank: Font {
        Font.system(size: 24, weight: .bold, design: .rounded)
    }
    
    static var leaderboardName: Font {
        Font.system(size: 17, weight: .semibold, design: .default)
    }
    
    static var leaderboardScore: Font {
        Font.system(size: 20, weight: .bold, design: .monospaced)
    }
    
    // Achievement specific
    static var achievementTitle: Font {
        Font.system(size: 18, weight: .semibold, design: .rounded)
    }
    
    static var achievementDescription: Font {
        Font.system(size: 14, weight: .regular, design: .default)
    }
    
    // Card specific
    static var cardTitle: Font {
        Font.system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static var cardSubtitle: Font {
        Font.system(size: 15, weight: .regular, design: .default)
    }
    
    // Button specific
    static var primaryButton: Font {
        Font.system(size: 17, weight: .semibold, design: .rounded)
    }
    
    static var secondaryButton: Font {
        Font.system(size: 16, weight: .medium, design: .rounded)
    }
    
    // MARK: - Dynamic Type Scales
    static func scaledFont(_ baseSize: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        Font.custom("System", size: baseSize, relativeTo: textStyle)
    }
}
