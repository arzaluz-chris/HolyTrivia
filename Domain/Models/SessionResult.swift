// Domain/Models/SessionResult.swift

import Foundation

struct SessionResult: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let category: Category
    let correctCount: Int
    let totalQuestions: Int
    let xpEarned: Int
    let timeElapsed: TimeInterval
    let answers: [AnswerRecord]
    let streakBonus: Int
    let perfectBonus: Int
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        category: Category,
        correctCount: Int,
        totalQuestions: Int = 10,
        xpEarned: Int,
        timeElapsed: TimeInterval,
        answers: [AnswerRecord] = [],
        streakBonus: Int = 0,
        perfectBonus: Int = 0
    ) {
        self.id = id
        self.date = date
        self.category = category
        self.correctCount = correctCount
        self.totalQuestions = totalQuestions
        self.xpEarned = xpEarned
        self.timeElapsed = timeElapsed
        self.answers = answers
        self.streakBonus = streakBonus
        self.perfectBonus = perfectBonus
    }
    
    // Computed properties
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }
    
    var isPerfect: Bool {
        correctCount == totalQuestions
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard totalQuestions > 0 else { return 0 }
        return timeElapsed / Double(totalQuestions)
    }
    
    var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var shareText: String {
        String(localized: "share.result.text",
               defaultValue: "I scored \(correctCount)/\(totalQuestions) in \(category.displayName) on HolyTrivia! 🎉")
    }
}

struct AnswerRecord: Codable, Hashable {
    let questionId: UUID
    let selectedIndex: Int
    let isCorrect: Bool
    let timeSpent: TimeInterval
    
    init(
        questionId: UUID,
        selectedIndex: Int,
        isCorrect: Bool,
        timeSpent: TimeInterval
    ) {
        self.questionId = questionId
        self.selectedIndex = selectedIndex
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
    }
}
