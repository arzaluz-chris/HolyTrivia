// Domain/UseCases/XPCalculator.swift

import Foundation

struct XPCalculator {
    // MARK: - Constants
    private let baseXPPerCorrectAnswer = 10
    private let streakBonusIncrement = 20
    private let perfectScoreBonus = 100
    private let speedBonusThreshold: TimeInterval = 10 // seconds
    private let speedBonusXP = 5
    
    // MARK: - XP Calculation
    func calculateXP(
        correctAnswers: Int,
        totalQuestions: Int,
        averageTimePerQuestion: TimeInterval,
        currentStreak: Int,
        category: Category,
        difficulty: Question.Difficulty = .medium
    ) -> XPBreakdown {
        var breakdown = XPBreakdown()
        
        // Base XP for correct answers
        breakdown.baseXP = correctAnswers * baseXPPerCorrectAnswer
        
        // Apply difficulty multiplier
        breakdown.baseXP = Int(Double(breakdown.baseXP) * difficulty.xpMultiplier)
        
        // Streak bonus (cumulative)
        if currentStreak >= 5 {
            breakdown.streakBonus = streakBonusIncrement
        }
        if currentStreak >= 10 {
            breakdown.streakBonus += streakBonusIncrement
        }
        if currentStreak >= 15 {
            breakdown.streakBonus += streakBonusIncrement
        }
        
        // Perfect score bonus
        if correctAnswers == totalQuestions {
            breakdown.perfectBonus = perfectScoreBonus
        }
        
        // Speed bonus
        if averageTimePerQuestion < speedBonusThreshold && correctAnswers > 0 {
            breakdown.speedBonus = correctAnswers * speedBonusXP
        }
        
        // Category bonus (future feature)
        breakdown.categoryBonus = 0
        
        return breakdown
    }
    
    // MARK: - Level Calculation
    static func calculateLevel(from totalXP: Int) -> Int {
        // Level formula: level² × 75
        // Reverse: level = sqrt(totalXP / 75)
        let level = Int(sqrt(Double(totalXP) / 75.0))
        return max(1, level)
    }
    
    static func xpRequiredForLevel(_ level: Int) -> Int {
        // XP = level² × 75
        return level * level * 75
    }
    
    static func xpRequiredBetweenLevels(from currentLevel: Int) -> Int {
        let currentLevelXP = xpRequiredForLevel(currentLevel)
        let nextLevelXP = xpRequiredForLevel(currentLevel + 1)
        return nextLevelXP - currentLevelXP
    }
    
    // MARK: - XP Breakdown
    struct XPBreakdown {
        var baseXP: Int = 0
        var streakBonus: Int = 0
        var perfectBonus: Int = 0
        var speedBonus: Int = 0
        var categoryBonus: Int = 0
        
        var total: Int {
            baseXP + streakBonus + perfectBonus + speedBonus + categoryBonus
        }
        
        var bonusXP: Int {
            streakBonus + perfectBonus + speedBonus + categoryBonus
        }
        
        var hasAnyBonus: Bool {
            bonusXP > 0
        }
    }
}
