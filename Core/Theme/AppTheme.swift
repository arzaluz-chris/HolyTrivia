// Core/Theme/AppTheme.swift

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    enum Colors {
        // Primary Colors
        static let accent = Color("AccentColor")
        static let background = Color("BackgroundColor")
        static let primary = Color("PrimaryColor")
        static let gold = Color("GoldColor")
        
        // Category Colors
        static let oldTestament = Color("OldTestamentColor")
        static let newTestament = Color("NewTestamentColor")
        static let gospels = Color("GospelsColor")
        static let characters = Color("CharactersColor")
        static let wisdom = Color("WisdomColor")
        
        // Semantic Colors
        static let success = Color("GreenSuccess")
        static let error = Color("RedError")
        static let warning = Color("YellowWarning")
        
        // Neutral Colors
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let grayLight = Color("GrayLight")
        static let grayDark = Color("GrayDark")
    }
    
    // MARK: - Typography
    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title, design: .rounded).weight(.semibold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.medium)
        static let headline = Font.system(.headline, design: .rounded)
        static let body = Font.system(.body, design: .default)
        static let callout = Font.system(.callout, design: .default)
        static let subheadline = Font.system(.subheadline, design: .default)
        static let footnote = Font.system(.footnote, design: .default)
        static let caption = Font.system(.caption, design: .default)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxxSmall: CGFloat = 2
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
        static let xxxLarge: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
        static let card: CGFloat = 20
    }
    
    // MARK: - Shadow
    enum Shadow {
        static let small = ShadowStyle(
            color: Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
        
        static let card = ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 10,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let bounce = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
    
    // MARK: - Theme Accessors
    static let colors = Colors.self
    static let typography = Typography.self
    static let spacing = Spacing.self
    static let cornerRadius = CornerRadius.self
    static let shadow = Shadow.self
    static let animation = Animation.self
}

// MARK: - Shadow Style
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.card)
            .shadow(
                color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
    }
}

struct PrimaryButtonStyle: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.medium)
            .background(isEnabled ? AppTheme.Colors.primary : AppTheme.Colors.grayLight)
            .cornerRadius(AppTheme.CornerRadius.large)
            .scaleEffect(isEnabled ? 1.0 : 0.95)
            .animation(AppTheme.Animation.quick, value: isEnabled)
    }
}

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.medium)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.primary, lineWidth: 2)
            )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButton() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    func secondaryButton() -> some View {
        modifier(SecondaryButtonStyle())
    }
}
