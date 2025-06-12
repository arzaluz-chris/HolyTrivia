// Domain/Models/Achievement.swift

import Foundation

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let xpReward: Int
    let requirement: AchievementRequirement
    var unlockedDate: Date?
    
    var isUnlocked: Bool {
        unlockedDate != nil
    }
    
    static let allAchievements: [Achievement] = [
        // Streak Achievements
        Achievement(
            id: "streak_7",
            name: String(localized: "achievement.streak7.name"),
            description: String(localized: "achievement.streak7.description"),
            icon: "flame.fill",
            xpReward: 100,
            requirement: .streak(days: 7)
        ),
        Achievement(
            id: "streak_30",
            name: String(localized: "achievement.streak30.name"),
            description: String(localized: "achievement.streak30.description"),
            icon: "flame.fill",
            xpReward: 500,
            requirement: .streak(days: 30)
        ),
        
        // Perfect Score Achievements
        Achievement(
            id: "first_perfect",
            name: String(localized: "achievement.first_perfect.name"),
            description: String(localized: "achievement.first_perfect.description"),
            icon: "star.fill",
            xpReward: 50,
            requirement: .perfectScores(count: 1)
        ),
        Achievement(
            id: "perfect_master",
            name: String(localized: "achievement.perfect_master.name"),
            description: String(localized: "achievement.perfect_master.description"),
            icon: "star.circle.fill",
            xpReward: 200,
            requirement: .perfectScores(count: 10)
        ),
        
        // Category Achievements
        Achievement(
            id: "category_explorer",
            name: String(localized: "achievement.category_explorer.name"),
            description: String(localized: "achievement.category_explorer.description"),
            icon: "square.grid.2x2.fill",
            xpReward: 100,
            requirement: .playAllCategories
        ),
        Achievement(
            id: "old_testament_master",
            name: String(localized: "achievement.old_testament_master.name"),
            description: String(localized: "achievement.old_testament_master.description"),
            icon: "book.fill",
            xpReward: 150,
            requirement: .categoryMastery(category: .oldTestament, gamesPlayed: 50)
        ),
        
        // Level Achievements
        Achievement(
            id: "level_10",
            name: String(localized: "achievement.level10.name"),
            description: String(localized: "achievement.level10.description"),
            icon: "graduationcap.fill",
            xpReward: 200,
            requirement: .reachLevel(level: 10)
        ),
        Achievement(
            id: "level_25",
            name: String(localized: "achievement.level25.name"),
            description: String(localized: "achievement.level25.description"),
            icon: "crown.fill",
            xpReward: 500,
            requirement: .reachLevel(level: 25)
        ),
        
        // Speed Achievements
        Achievement(
            id: "speed_demon",
            name: String(localized: "achievement.speed_demon.name"),
            description: String(localized: "achievement.speed_demon.description"),
            icon: "bolt.fill",
            xpReward: 100,
            requirement: .completeQuizUnderTime(seconds: 120)
        ),
        
        // Accuracy Achievements
        Achievement(
            id: "sharpshooter",
            name: String(localized: "achievement.sharpshooter.name"),
            description: String(localized: "achievement.sharpshooter.description"),
            icon: "target",
            xpReward: 150,
            requirement: .maintainAccuracy(percentage: 90, games: 10)
        ),
        
        // Total Questions
        Achievement(
            id: "question_100",
            name: String(localized: "achievement.question100.name"),
            description: String(localized: "achievement.question100.description"),
            icon: "questionmark.circle.fill",
            xpReward: 50,
            requirement: .answerQuestions(count: 100)
        ),
        Achievement(
            id: "question_1000",
            name: String(localized: "achievement.question1000.name"),
            description: String(localized: "achievement.question1000.description"),
            icon: "questionmark.diamond.fill",
            xpReward: 300,
            requirement: .answerQuestions(count: 1000)
        )
    ]
}

enum AchievementRequirement: Codable, Hashable {
    case streak(days: Int)
    case perfectScores(count: Int)
    case playAllCategories
    case categoryMastery(category: Category, gamesPlayed: Int)
    case reachLevel(level: Int)
    case completeQuizUnderTime(seconds: Int)
    case maintainAccuracy(percentage: Int, games: Int)
    case answerQuestions(count: Int)
    
    func evaluate(player: Player, recentResult: SessionResult? = nil) -> Bool {
        switch self {
        case .streak(let days):
            return player.currentStreak >= days
            
        case .perfectScores(let count):
            let perfectCount = player.categoryStats.values.reduce(0) { $0 + $1.perfectGames }
            return perfectCount >= count
            
        case .playAllCategories:
            return player.categoryStats.keys.count == Category.allCases.count
            
        case .categoryMastery(let category, let gamesPlayed):
            return player.categoryStats[category]?.gamesPlayed ?? 0 >= gamesPlayed
            
        case .reachLevel(let level):
            return player.level >= level
            
        case .completeQuizUnderTime(let seconds):
            guard let result = recentResult else { return false }
            return result.timeElapsed <= TimeInterval(seconds)
            
        case .maintainAccuracy(let percentage, let games):
            guard player.totalGamesPlayed >= games else { return false }
            return player.overallAccuracy * 100 >= Double(percentage)
            
        case .answerQuestions(let count):
            return player.totalQuestionsAnswered >= count
        }
    }
}
