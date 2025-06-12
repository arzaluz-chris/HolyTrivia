// Core/Extensions/View+Extensions.swift

import SwiftUI

extension View {
    // MARK: - Conditional Modifiers
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // MARK: - Loading Overlay
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        )
                }
            }
        )
    }
    
    // MARK: - Shake Effect
    func shake(_ times: Int = 3, amplitude: CGFloat = 5) -> some View {
        self.modifier(ShakeEffect(times: times, amplitude: amplitude))
    }
    
    // MARK: - Success/Error Animation
    func feedbackAnimation(isCorrect: Bool?, duration: Double = 0.3) -> some View {
        self
            .scaleEffect(isCorrect != nil ? (isCorrect! ? 1.05 : 0.95) : 1.0)
            .animation(.easeInOut(duration: duration), value: isCorrect)
    }
    
    // MARK: - Keyboard Handling
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func onKeyboardAppear(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            action()
        }
    }
    
    func onKeyboardDisappear(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            action()
        }
    }
    
    // MARK: - Corner Radius with Border
    func cornerRadiusWithBorder(radius: CGFloat, borderColor: Color, borderWidth: CGFloat = 1) -> some View {
        self
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
    
    // MARK: - Glow Effect
    func glow(color: Color = .white, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}

// MARK: - Shake Effect Modifier
struct ShakeEffect: GeometryEffect {
    var times: Int
    var amplitude: CGFloat
    var animatableData: CGFloat = 0
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = sin(animatableData * .pi * CGFloat(times)) * amplitude
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
