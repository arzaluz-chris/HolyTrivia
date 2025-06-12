// Core/Utilities/HapticManager.swift

import SwiftUI
import CoreHaptics

@MainActor
final class HapticManager: ObservableObject {
    // MARK: - Published Properties
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled = true
    
    // MARK: - Private Properties
    private var engine: CHHapticEngine?
    private let impactFeedback = UIImpactFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    // MARK: - Haptic Types
    enum HapticType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case selection
        case custom(intensity: Float, sharpness: Float, duration: TimeInterval)
    }
    
    // MARK: - Initialization
    init() {
        setupHapticEngine()
        prepareGenerators()
    }
    
    // MARK: - Public Methods
    func play(_ type: HapticType) {
        guard hapticFeedbackEnabled else { return }
        
        switch type {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
            
        case .notification(let feedbackType):
            notificationFeedback.notificationOccurred(feedbackType)
            
        case .selection:
            selectionFeedback.selectionChanged()
            
        case .custom(let intensity, let sharpness, let duration):
            playCustomHaptic(intensity: intensity, sharpness: sharpness, duration: duration)
        }
    }
    
    // Convenience methods for common haptics
    func playCorrectAnswer() {
        play(.notification(.success))
    }
    
    func playIncorrectAnswer() {
        play(.notification(.error))
    }
    
    func playButtonTap() {
        play(.impact(.light))
    }
    
    func playLevelUp() {
        play(.custom(intensity: 1.0, sharpness: 0.5, duration: 0.5))
    }
    
    func playStreakBonus() {
        play(.custom(intensity: 0.8, sharpness: 0.8, duration: 0.3))
    }
    
    func playCountdown() {
        play(.impact(.medium))
    }
    
    // MARK: - Private Methods
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    private func prepareGenerators() {
        impactFeedback.prepare()
        notificationFeedback.prepare()
        selectionFeedback.prepare()
    }
    
    private func playCustomHaptic(intensity: Float, sharpness: Float, duration: TimeInterval) {
        guard let engine = engine else { return }
        
        let hapticEvent = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error)")
        }
    }
}
