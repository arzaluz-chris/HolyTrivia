// Data/Local/SwiftData/SwiftDataModels/QuestionSD.swift

import Foundation
import SwiftData

@Model
final class QuestionSD {
    @Attribute(.unique) var id: UUID
    var text: String
    var answers: [String]
    var correctIndex: Int
    var categoryRawValue: String
    var difficultyRawValue: String
    var explanation: String?
    var bibleReference: String?
    var createdDate: Date
    var lastModified: Date
    
    init(
        id: UUID = UUID(),
        text: String,
        answers: [String],
        correctIndex: Int,
        category: Category,
        difficulty: Question.Difficulty = .medium,
        explanation: String? = nil,
        bibleReference: String? = nil
    ) {
        self.id = id
        self.text = text
        self.answers = answers
        self.correctIndex = correctIndex
        self.categoryRawValue = category.rawValue
        self.difficultyRawValue = difficulty.rawValue
        self.explanation = explanation
        self.bibleReference = bibleReference
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // Convert to domain model
    func toDomainModel() -> Question? {
        guard let category = Category(rawValue: categoryRawValue),
              let difficulty = Question.Difficulty(rawValue: difficultyRawValue) else {
            return nil
        }
        
        return Question(
            id: id,
            text: text,
            answers: answers,
            correctIndex: correctIndex,
            category: category,
            difficulty: difficulty,
            explanation: explanation,
            bibleReference: bibleReference
        )
    }
    
    // Update from domain model
    func update(from question: Question) {
        self.text = question.text
        self.answers = question.answers
        self.correctIndex = question.correctIndex
        self.categoryRawValue = question.category.rawValue
        self.difficultyRawValue = question.difficulty.rawValue
        self.explanation = question.explanation
        self.bibleReference = question.bibleReference
        self.lastModified = Date()
    }
    
    // Create from domain model
    static func from(_ question: Question) -> QuestionSD {
        QuestionSD(
            id: question.id,
            text: question.text,
            answers: question.answers,
            correctIndex: question.correctIndex,
            category: question.category,
            difficulty: question.difficulty,
            explanation: question.explanation,
            bibleReference: question.bibleReference
        )
    }
}
