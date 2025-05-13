// QuizResult.swift
import Foundation

struct QuizResult: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var categoryId: String
    var questionsCount: Int
    var correctAnswers: Int
    var timeSpent: TimeInterval
    
    var score: Int {
        return correctAnswers
    }
    
    var accuracy: Double {
        return Double(correctAnswers) / Double(questionsCount)
    }
}
