// UserStats.swift
import Foundation

struct UserStats: Codable {
    var totalGames: Int
    var totalCorrectAnswers: Int
    var totalQuestions: Int
    var highScore: Int
    var lastPlayed: Date?
    var categoryStats: [CategoryStat]
    
    var overallAccuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestions)
    }
    
    static var empty: UserStats {
        return UserStats(
            totalGames: 0,
            totalCorrectAnswers: 0,
            totalQuestions: 0,
            highScore: 0,
            lastPlayed: nil,
            categoryStats: []
        )
    }
}

struct CategoryStat: Codable, Identifiable {
    var id: String
    var categoryId: String
    var answeredQuestions: Int
    var correctAnswers: Int
    var totalQuestions: Int
    
    var accuracy: Double {
        guard answeredQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(answeredQuestions)
    }
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(answeredQuestions) / Double(totalQuestions)
    }
}
