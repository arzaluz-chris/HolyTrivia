// Presentation/SharedComponents/CustomTabBar.swift

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.appTheme) private var theme
    
    let tabs: [(icon: String, title: String)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                TabBarItem(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(theme.animation.quick) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, theme.spacing.small)
        .padding(.vertical, theme.spacing.xSmall)
        .background(
            Color.white
                .shadow(
                    color: theme.shadow.small.color,
                    radius: theme.shadow.small.radius,
                    x: 0,
                    y: -2
                )
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.appTheme) private var theme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: theme.spacing.xxxSmall) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? theme.colors.primary : theme.colors.grayDark)
                
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundColor(isSelected ? theme.colors.primary : theme.colors.grayDark)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.xSmall)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(theme.animation.quick, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { _ in
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}
