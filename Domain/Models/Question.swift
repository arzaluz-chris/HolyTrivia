// Domain/Models/Question.swift

import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let answers: [String]
    let correctIndex: Int
    let category: Category
    let difficulty: Difficulty
    let explanation: String?
    let bibleReference: String?
    
    init(
        id: UUID = UUID(),
        text: String,
        answers: [String],
        correctIndex: Int,
        category: Category,
        difficulty: Difficulty = .medium,
        explanation: String? = nil,
        bibleReference: String? = nil
    ) {
        self.id = id
        self.text = text
        self.answers = answers
        self.correctIndex = correctIndex
        self.category = category
        self.difficulty = difficulty
        self.explanation = explanation
        self.bibleReference = bibleReference
    }
    
    enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
        
        var xpMultiplier: Double {
            switch self {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            }
        }
    }
    
    // Validation
    var isValid: Bool {
        answers.count == 4 &&
        correctIndex >= 0 &&
        correctIndex < answers.count &&
        !text.isEmpty &&
        answers.allSatisfy { !$0.isEmpty }
    }
    
    // Get correct answer text
    var correctAnswer: String {
        guard isValid else { return "" }
        return answers[correctIndex]
    }
}
