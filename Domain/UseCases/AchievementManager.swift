// Domain/UseCases/AchievementManager.swift

import Foundation
import Combine

final class AchievementManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var unlockedAchievements: Set<String> = []
    @Published private(set) var recentlyUnlocked: [Achievement] = []
    
    // MARK: - Private Properties
    private let playerRepository: PlayerRepositoryProtocol
    private var player: Player?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(playerRepository: PlayerRepositoryProtocol) {
        self.playerRepository = playerRepository
        loadAchievements()
    }
    
    // MARK: - Public Methods
    func checkAchievements(for player: Player, afterSession result: SessionResult? = nil) async -> [Achievement] {
        self.player = player
        var newlyUnlocked: [Achievement] = []
        
        for achievement in Achievement.allAchievements {
            // Skip if already unlocked
            if unlockedAchievements.contains(achievement.id) {
                continue
            }
            
            // Check if requirement is met
            if achievement.requirement.evaluate(player: player, recentResult: result) {
                // Unlock achievement
                unlockedAchievements.insert(achievement.id)
                
                var unlockedAchievement = achievement
                unlockedAchievement.unlockedDate = Date()
                newlyUnlocked.append(unlockedAchievement)
                
                // Update player XP
                await awardXP(achievement.xpReward)
            }
        }
        
        // Update recently unlocked for UI
        if !newlyUnlocked.isEmpty {
            recentlyUnlocked = newlyUnlocked
            await saveAchievements()
        }
        
        return newlyUnlocked
    }
    
    func getAchievement(by id: String) -> Achievement? {
        Achievement.allAchievements.first { $0.id == id }
    }
    
    func getProgress(for achievement: Achievement, player: Player) -> AchievementProgress {
        switch achievement.requirement {
        case .streak(let days):
            return AchievementProgress(
                current: player.currentStreak,
                target: days,
                percentage: min(100, Double(player.currentStreak) / Double(days) * 100)
            )
            
        case .perfectScores(let count):
            let perfectCount = player.categoryStats.values.reduce(0) { $0 + $1.perfectGames }
            return AchievementProgress(
                current: perfectCount,
                target: count,
                percentage: min(100, Double(perfectCount) / Double(count) * 100)
            )
            
        case .playAllCategories:
            let playedCategories = player.categoryStats.keys.count
            let totalCategories = Category.allCases.count
            return AchievementProgress(
                current: playedCategories,
                target: totalCategories,
                percentage: min(100, Double(playedCategories) / Double(totalCategories) * 100)
            )
            
        case .categoryMastery(let category, let gamesPlayed):
            let played = player.categoryStats[category]?.gamesPlayed ?? 0
            return AchievementProgress(
                current: played,
                target: gamesPlayed,
                percentage: min(100, Double(played) / Double(gamesPlayed) * 100)
            )
            
        case .reachLevel(let level):
            return AchievementProgress(
                current: player.level,
                target: level,
                percentage: min(100, Double(player.level) / Double(level) * 100)
            )
            
        case .answerQuestions(let count):
            return AchievementProgress(
                current: player.totalQuestionsAnswered,
                target: count,
                percentage: min(100, Double(player.totalQuestionsAnswered) / Double(count) * 100)
            )
            
        case .completeQuizUnderTime:
            // Special case - binary achievement
            return AchievementProgress(
                current: 0,
                target: 1,
                percentage: 0
            )
            
        case .maintainAccuracy(let percentage, let games):
            let hasEnoughGames = player.totalGamesPlayed >= games
            let meetsAccuracy = player.overallAccuracy * 100 >= Double(percentage)
            return AchievementProgress(
                current: hasEnoughGames && meetsAccuracy ? 1 : 0,
                target: 1,
                percentage: hasEnoughGames && meetsAccuracy ? 100 : 0
            )
        }
    }
    
    func clearRecentlyUnlocked() {
        recentlyUnlocked = []
    }
    
    // MARK: - Private Methods
    private func loadAchievements() {
        Task {
            do {
                if let player = try await playerRepository.getCurrentPlayer() {
                    await MainActor.run {
                        self.unlockedAchievements = player.achievements
                    }
                }
            } catch {
                print("Failed to load achievements: \(error)")
            }
        }
    }
    
    private func saveAchievements() async {
        guard var player = self.player else { return }
        player.achievements = unlockedAchievements
        
        do {
            try await playerRepository.updatePlayer(player)
        } catch {
            print("Failed to save achievements: \(error)")
        }
    }
    
    private func awardXP(_ xp: Int) async {
        guard var player = self.player else { return }
        player.totalXP += xp
        
        // Recalculate level
        let newLevel = XPCalculator.calculateLevel(from: player.totalXP)
        if newLevel > player.level {
            player.level = newLevel
        }
        
        do {
            try await playerRepository.updatePlayer(player)
            self.player = player
        } catch {
            print("Failed to update player XP: \(error)")
        }
    }
}

// MARK: - Achievement Progress
struct AchievementProgress {
    let current: Int
    let target: Int
    let percentage: Double
    
    var isComplete: Bool {
        percentage >= 100
    }
    
    var progressText: String {
        "\(current) / \(target)"
    }
}
