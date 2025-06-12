// Presentation/Screens/Leaderboard/LeaderboardViewModel.swift

import SwiftUI
import Combine

@MainActor
final class LeaderboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var players: [Player] = []
    @Published private(set) var currentPlayer: Player?
    @Published private(set) var currentPlayerRank: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func loadLeaderboard(appContainer: AppContainer) async {
        isLoading = true
        error = nil
        
        do {
            // Get leaderboard
            players = try await appContainer.playerRepository.getLeaderboard(limit: 50)
            
            // Get current player
            currentPlayer = try await appContainer.playerRepository.getCurrentPlayer()
            
            // Find current player rank
            if let currentPlayer = currentPlayer {
                currentPlayerRank = players.firstIndex(where: { $0.id == currentPlayer.id }).map { $0 + 1 }
                
                // If current player not in top 50, add them separately
                if currentPlayerRank == nil {
                    // Calculate actual rank
                    let allPlayers = try await appContainer.playerRepository.getLeaderboard(limit: 1000)
                    currentPlayerRank = allPlayers.firstIndex(where: { $0.id == currentPlayer.id }).map { $0 + 1 }
                }
            }
            
            isLoading = false
        } catch {
            self.error = error
            print("Failed to load leaderboard: \(error)")
            isLoading = false
        }
    }
    
    func refreshLeaderboard(appContainer: AppContainer) async {
        await loadLeaderboard(appContainer: appContainer)
    }
}
