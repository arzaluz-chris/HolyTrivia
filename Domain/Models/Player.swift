// Domain/Models/Player.swift

import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var username: String
    var totalXP: Int
    var level: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastPlayedDate: Date?
    var achievements: Set<String>
    var categoryStats: [Category: CategoryStat]
    var createdDate: Date
    var preferredCategories: [Category]
    
    init(
        id: UUID = UUID(),
        username: String = "",
        totalXP: Int = 0,
        level: Int = 1,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastPlayedDate: Date? = nil,
        achievements: Set<String> = [],
        categoryStats: [Category: CategoryStat] = [:],
        createdDate: Date = Date(),
        preferredCategories: [Category] = []
    ) {
        self.id = id
        self.username = username
        self.totalXP = totalXP
        self.level = level
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastPlayedDate = lastPlayedDate
        self.achievements = achievements
        self.categoryStats = categoryStats
        self.createdDate = createdDate
        self.preferredCategories = preferredCategories
    }
    
    // XP calculations
    var xpForCurrentLevel: Int {
        XPCalculator.xpRequiredForLevel(level)
    }
    
    var xpForNextLevel: Int {
        XPCalculator.xpRequiredForLevel(level + 1)
    }
    
    var xpProgressInCurrentLevel: Int {
        totalXP - xpForCurrentLevel
    }
    
    var xpNeededForNextLevel: Int {
        xpForNextLevel - totalXP
    }
    
    var levelProgress: Double {
        let totalXPNeeded = xpForNextLevel - xpForCurrentLevel
        guard totalXPNeeded > 0 else { return 0 }
        return Double(xpProgressInCurrentLevel) / Double(totalXPNeeded)
    }
    
    // Stats
    var totalGamesPlayed: Int {
        categoryStats.values.reduce(0) { $0 + $1.gamesPlayed }
    }
    
    var totalQuestionsAnswered: Int {
        categoryStats.values.reduce(0) { $0 + $1.questionsAnswered }
    }
    
    var totalCorrectAnswers: Int {
        categoryStats.values.reduce(0) { $0 + $1.correctAnswers }
    }
    
    var overallAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }
    
    var favoriteCategory: Category? {
        categoryStats.max(by: { $0.value.gamesPlayed < $1.value.gamesPlayed })?.key
    }
    
    // Streak management
    mutating func updateStreak(playedToday: Bool) {
        guard let lastPlayed = lastPlayedDate else {
            if playedToday {
                currentStreak = 1
                longestStreak = max(longestStreak, 1)
            }
            return
        }
        
        let calendar = Calendar.current
        let daysSinceLastPlay = calendar.dateComponents([.day], from: lastPlayed, to: Date()).day ?? 0
        
        if daysSinceLastPlay == 0 && playedToday {
            // Already played today
            return
        } else if daysSinceLastPlay == 1 && playedToday {
            // Consecutive day
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else if daysSinceLastPlay > 1 && playedToday {
            // Streak broken
            currentStreak = 1
        }
        
        if playedToday {
            lastPlayedDate = Date()
        }
    }
}

struct CategoryStat: Codable, Hashable {
    var gamesPlayed: Int = 0
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var totalXPEarned: Int = 0
    var bestScore: Int = 0
    var perfectGames: Int = 0
    var averageScore: Double = 0
    var lastPlayed: Date?
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
    
    mutating func updateStats(with result: SessionResult) {
        gamesPlayed += 1
        questionsAnswered += result.totalQuestions
        correctAnswers += result.correctCount
        totalXPEarned += result.xpEarned
        bestScore = max(bestScore, result.correctCount)
        if result.isPerfect {
            perfectGames += 1
        }
        
        // Update average score
        let newTotal = (averageScore * Double(gamesPlayed - 1)) + Double(result.correctCount)
        averageScore = newTotal / Double(gamesPlayed)
        
        lastPlayed = Date()
    }
}
