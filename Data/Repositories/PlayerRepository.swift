// Data/Repositories/PlayerRepository.swift

import Foundation
import SwiftData

@MainActor
final class PlayerRepository: PlayerRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    func getCurrentPlayer() async throws -> Player? {
        let descriptor = FetchDescriptor<PlayerSD>(
            sortBy: [SortDescriptor(\.createdDate, order: .forward)]
        )
        
        // For MVP, we assume single player
        if let playerSD = try modelContext.fetch(descriptor).first {
            return playerSD.toDomainModel()
        }
        
        return nil
    }
    
    func createPlayer(_ player: Player) async throws {
        let playerSD = PlayerSD.from(player)
        modelContext.insert(playerSD)
        try modelContext.save()
    }
    
    func updatePlayer(_ player: Player) async throws {
        let descriptor = FetchDescriptor<PlayerSD>(
            predicate: #Predicate { p in
                p.id == player.id
            }
        )
        
        if let playerSD = try modelContext.fetch(descriptor).first {
            playerSD.update(from: player)
            try modelContext.save()
        } else {
            throw RepositoryError.playerNotFound
        }
    }
    
    func deletePlayer(_ player: Player) async throws {
        let descriptor = FetchDescriptor<PlayerSD>(
            predicate: #Predicate { p in
                p.id == player.id
            }
        )
        
        if let playerSD = try modelContext.fetch(descriptor).first {
            modelContext.delete(playerSD)
            try modelContext.save()
        }
    }
    
    func updatePlayerStats(with sessionResult: SessionResult) async throws {
        guard var player = try await getCurrentPlayer() else {
            throw RepositoryError.playerNotFound
        }
        
        // Update player stats
        player.totalXP += sessionResult.xpEarned
        
        // Recalculate level
        let newLevel = XPCalculator.calculateLevel(from: player.totalXP)
        if newLevel > player.level {
            player.level = newLevel
        }
        
        // Update category stats
        var categoryStats = player.categoryStats[sessionResult.category] ?? CategoryStat()
        categoryStats.updateStats(with: sessionResult)
        player.categoryStats[sessionResult.category] = categoryStats
        
        // Update streak
        player.updateStreak(playedToday: true)
        
        // Save updated player
        try await updatePlayer(player)
        
        // Save session result
        let sessionSD = SessionResultSD.from(sessionResult)
        
        // Link to player
        let descriptor = FetchDescriptor<PlayerSD>(
            predicate: #Predicate { p in
                p.id == player.id
            }
        )
        
        if let playerSD = try modelContext.fetch(descriptor).first {
            sessionSD.player = playerSD
            modelContext.insert(sessionSD)
            try modelContext.save()
        }
    }
    
    func getLeaderboard(limit: Int) async throws -> [Player] {
        let descriptor = FetchDescriptor<PlayerSD>(
            sortBy: [
                SortDescriptor(\.totalXP, order: .reverse),
                SortDescriptor(\.level, order: .reverse)
            ]
        )
        
        var fetchDescriptor = descriptor
        fetchDescriptor.fetchLimit = limit
        
        let playerSDs = try modelContext.fetch(fetchDescriptor)
        return playerSDs.map { $0.toDomainModel() }
    }
}

// MARK: - Error Types
enum RepositoryError: LocalizedError {
    case playerNotFound
    case sessionNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .playerNotFound:
            return "Player data not found"
        case .sessionNotFound:
            return "Session data not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
