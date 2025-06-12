// Core/Extensions/Font+Extensions.swift

import SwiftUI

extension Font {
    // MARK: - Custom Font Weights
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
    
    static func monospaced(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .monospaced)
    }
    
    // MARK: - Dynamic Type Support
    static func dynamicTitle(_ size: CGFloat = 34) -> Font {
        return Font.custom("System", size: size, relativeTo: .largeTitle)
    }
    
    static func dynamicHeadline(_ size: CGFloat = 17) -> Font {
        return Font.custom("System", size: size, relativeTo: .headline)
    }
    
    static func dynamicBody(_ size: CGFloat = 17) -> Font {
        return Font.custom("System", size: size, relativeTo: .body)
    }
    
    static func dynamicCaption(_ size: CGFloat = 12) -> Font {
        return Font.custom("System", size: size, relativeTo: .caption)
    }
    
    // MARK: - App Specific Fonts
    static var quizQuestion: Font {
        return .system(size: 22, weight: .semibold, design: .rounded)
    }
    
    static var quizAnswer: Font {
        return .system(size: 18, weight: .medium, design: .default)
    }
    
    static var scoreDisplay: Font {
        return .system(size: 48, weight: .bold, design: .rounded)
    }
    
    static var xpDisplay: Font {
        return .system(size: 32, weight: .bold, design: .rounded)
    }
}
