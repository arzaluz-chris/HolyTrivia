// Presentation/Screens/Onboarding/OnboardingViewModel.swift

import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPage: Int = 0
    @Published var username: String = ""
    @Published var selectedCategories: Set<Category> = []
    @Published var notificationsEnabled: Bool = false
    
    // MARK: - Properties
    let totalPages = 4
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Onboarding Pages Data
    let pages: [OnboardingPageData] = [
        OnboardingPageData(
            icon: "book.fill",
            title: "Welcome to HolyTrivia",
            description: "Test your Bible knowledge with fun, engaging quizzes across multiple categories.",
            color: AppTheme.Colors.primary
        ),
        OnboardingPageData(
            icon: "star.fill",
            title: "Earn XP & Level Up",
            description: "Answer questions correctly to earn experience points and unlock achievements.",
            color: AppTheme.Colors.gold
        ),
        OnboardingPageData(
            icon: "flame.fill",
            title: "Build Your Streak",
            description: "Play daily to maintain your streak and earn bonus rewards.",
            color: .orange
        ),
        OnboardingPageData(
            icon: "bell.badge.fill",
            title: "Stay Motivated",
            description: "Get daily reminders to keep your streak alive and continue learning.",
            color: AppTheme.Colors.primary
        )
    ]
    
    // MARK: - Public Methods
    func nextPage() {
        if currentPage < totalPages - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func completeOnboarding(appContainer: AppContainer) async {
        // Save user preferences
        UserDefaultsManager.shared.hasCompletedOnboarding = true
        
        // Update player name if provided
        if !username.isEmpty {
            await updatePlayerName(appContainer: appContainer)
        }
        
        // Save preferred categories
        if !selectedCategories.isEmpty {
            await savePreferredCategories(appContainer: appContainer)
        }
        
        // Request notification permissions if enabled
        if notificationsEnabled {
            await requestNotificationPermissions()
        }
    }
    
    // MARK: - Private Methods
    private func updatePlayerName(appContainer: AppContainer) async {
        do {
            if var player = try await appContainer.playerRepository.getCurrentPlayer() {
                player.username = username
                try await appContainer.playerRepository.updatePlayer(player)
            }
        } catch {
            print("Failed to update player name: \(error)")
        }
    }
    
    private func savePreferredCategories(appContainer: AppContainer) async {
        do {
            if var player = try await appContainer.playerRepository.getCurrentPlayer() {
                player.preferredCategories = Array(selectedCategories)
                try await appContainer.playerRepository.updatePlayer(player)
            }
        } catch {
            print("Failed to save preferred categories: \(error)")
        }
    }
    
    private func requestNotificationPermissions() async {
        // Future implementation for push notifications
        // UNUserNotificationCenter.current().requestAuthorization...
    }
}

// MARK: - Supporting Types
struct OnboardingPageData {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
