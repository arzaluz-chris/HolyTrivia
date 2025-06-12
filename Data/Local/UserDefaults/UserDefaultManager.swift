// Data/Local/UserDefaults/UserDefaultsManager.swift

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let container: UserDefaults = .standard
    
    var wrappedValue: T {
        get {
            container.object(forKey: key) as? T ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
    
    var projectedValue: AnyPublisher<T, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in self.wrappedValue }
            .prepend(self.wrappedValue)
            .removeDuplicates(by: { (try? JSONEncoder().encode(AnyEncodable($0))) == (try? JSONEncoder().encode(AnyEncodable($1))) })
            .eraseToAnyPublisher()
    }
}

final class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    // MARK: - Settings
    @UserDefault(key: "soundEffectsEnabled", defaultValue: true)
    var soundEffectsEnabled: Bool
    
    @UserDefault(key: "hapticFeedbackEnabled", defaultValue: true)
    var hapticFeedbackEnabled: Bool
    
    @UserDefault(key: "cloudSyncEnabled", defaultValue: false)
    var cloudSyncEnabled: Bool
    
    @UserDefault(key: "colorScheme", defaultValue: "system")
    var colorScheme: String
    
    // MARK: - Game Settings
    @UserDefault(key: "preferredDifficulty", defaultValue: "medium")
    var preferredDifficulty: String
    
    @UserDefault(key: "showTimer", defaultValue: true)
    var showTimer: Bool
    
    @UserDefault(key: "autoAdvanceQuestions", defaultValue: true)
    var autoAdvanceQuestions: Bool
    
    // MARK: - User Preferences
    @UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    var hasCompletedOnboarding: Bool
    
    @UserDefault(key: "lastPlayedCategory", defaultValue: nil)
    var lastPlayedCategory: String?
    
    @UserDefault(key: "preferredLanguage", defaultValue: "en")
    var preferredLanguage: String
    
    // MARK: - Statistics
    @UserDefault(key: "totalGamesPlayed", defaultValue: 0)
    var totalGamesPlayed: Int
    
    @UserDefault(key: "lastSyncDate", defaultValue: nil)
    var lastSyncDate: Date?
    
    // MARK: - Methods
    func resetSettings() {
        soundEffectsEnabled = true
        hapticFeedbackEnabled = true
        showTimer = true
        autoAdvanceQuestions = true
        preferredDifficulty = "medium"
    }
    
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Helper for Codable in UserDefaults
fileprivate struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    init<T>(_ wrapped: T) {
        if let encodable = wrapped as? Encodable {
            _encode = encodable.encode
        } else {
            _encode = { _ in }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
