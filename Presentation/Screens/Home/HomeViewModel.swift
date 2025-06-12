// Presentation/Screens/Home/HomeViewModel.swift

import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var player: Player?
    @Published private(set) var categoryQuestionCounts: [Category: Int] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func loadData(appContainer: AppContainer) async {
        isLoading = true
        error = nil
        
        do {
            // Load player data
            player = try await appContainer.playerRepository.getCurrentPlayer()
            
            // Load question counts for each category
            var counts: [Category: Int] = [:]
            for category in Category.allCases {
                let count = try await appContainer.questionRepository.getQuestionCount(for: category)
                counts[category] = count
            }
            
            await MainActor.run {
                self.categoryQuestionCounts = counts
                self.isLoading = false
            }
            
            // Check for streak updates
            if let player = player {
                checkAndUpdateStreak(player: player, appContainer: appContainer)
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            print("Error loading home data: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func checkAndUpdateStreak(player: Player, appContainer: AppContainer) {
        let streakInfo = StreakTracker.calculateStreak(
            lastPlayedDate: player.lastPlayedDate,
            currentStreak: player.currentStreak
        )
        
        if streakInfo.shouldResetStreak {
            Task {
                var updatedPlayer = player
                updatedPlayer.currentStreak = 0
                
                do {
                    try await appContainer.playerRepository.updatePlayer(updatedPlayer)
                    await MainActor.run {
                        self.player = updatedPlayer
                    }
                } catch {
                    print("Failed to update player streak: \(error)")
                }
            }
        }
    }
}
