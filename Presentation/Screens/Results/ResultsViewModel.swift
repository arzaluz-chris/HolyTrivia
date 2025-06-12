// Presentation/Screens/Results/ResultsViewModel.swift

import SwiftUI
import Combine

@MainActor
final class ResultsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var player: Player?
    @Published private(set) var xpBreakdown: XPCalculator.XPBreakdown?
    @Published private(set) var unlockedAchievements: [Achievement] = []
    @Published private(set) var isProcessing = false
    
    // MARK: - Public Methods
    func processResults(
        sessionResult: SessionResult,
        appContainer: AppContainer
    ) async {
        isProcessing = true
        
        do {
            // Update player stats with session result
            try await appContainer.playerRepository.updatePlayerStats(with: sessionResult)
            
            // Get updated player
            if let updatedPlayer = try await appContainer.playerRepository.getCurrentPlayer() {
                player = updatedPlayer
                
                // Calculate XP breakdown
                xpBreakdown = XPCalculator.XPBreakdown(
                    baseXP: sessionResult.correctCount * 10,
                    streakBonus: sessionResult.streakBonus,
                    perfectBonus: sessionResult.perfectBonus,
                    speedBonus: 0,
                    categoryBonus: 0
                )
                
                // Check for new achievements
                let newAchievements = await appContainer.achievementManager.checkAchievements(
                    for: updatedPlayer,
                    afterSession: sessionResult
                )
                
                unlockedAchievements = newAchievements
            }
            
            isProcessing = false
        } catch {
            print("Failed to process results: \(error)")
            isProcessing = false
        }
    }
}
