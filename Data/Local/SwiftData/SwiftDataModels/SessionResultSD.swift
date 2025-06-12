// Data/Local/SwiftData/SwiftDataModels/SessionResultSD.swift

import Foundation
import SwiftData

@Model
final class SessionResultSD {
    @Attribute(.unique) var id: UUID
    var date: Date
    var categoryRawValue: String
    var correctCount: Int
    var totalQuestions: Int
    var xpEarned: Int
    var timeElapsed: TimeInterval
    var answersData: Data? // Encoded [AnswerRecord]
    var streakBonus: Int
    var perfectBonus: Int
    
    @Relationship var player: PlayerSD?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        category: Category,
        correctCount: Int,
        totalQuestions: Int = 10,
        xpEarned: Int,
        timeElapsed: TimeInterval,
        streakBonus: Int = 0,
        perfectBonus: Int = 0
    ) {
        self.id = id
        self.date = date
        self.categoryRawValue = category.rawValue
        self.correctCount = correctCount
        self.totalQuestions = totalQuestions
        self.xpEarned = xpEarned
        self.timeElapsed = timeElapsed
        self.streakBonus = streakBonus
        self.perfectBonus = perfectBonus
    }
    
    // Convert to domain model
    func toDomainModel() -> SessionResult? {
        guard let category = Category(rawValue: categoryRawValue) else {
            return nil
        }
        
        var answers: [AnswerRecord] = []
        if let data = answersData {
            answers = (try? JSONDecoder().decode([AnswerRecord].self, from: data)) ?? []
        }
        
        return SessionResult(
            id: id,
            date: date,
            category: category,
            correctCount: correctCount,
            totalQuestions: totalQuestions,
            xpEarned: xpEarned,
            timeElapsed: timeElapsed,
            answers: answers,
            streakBonus: streakBonus,
            perfectBonus: perfectBonus
        )
    }
    
    // Update from domain model
    func update(from session: SessionResult) {
        self.date = session.date
        self.categoryRawValue = session.category.rawValue
        self.correctCount = session.correctCount
        self.totalQuestions = session.totalQuestions
        self.xpEarned = session.xpEarned
        self.timeElapsed = session.timeElapsed
        self.streakBonus = session.streakBonus
        self.perfectBonus = session.perfectBonus
        
        // Encode answers
        if let data = try? JSONEncoder().encode(session.answers) {
            self.answersData = data
        }
    }
    
    // Create from domain model
    static func from(_ session: SessionResult) -> SessionResultSD {
        let sessionSD = SessionResultSD(
            id: session.id,
            date: session.date,
            category: session.category,
            correctCount: session.correctCount,
            totalQuestions: session.totalQuestions,
            xpEarned: session.xpEarned,
            timeElapsed: session.timeElapsed,
            streakBonus: session.streakBonus,
            perfectBonus: session.perfectBonus
        )
        
        // Encode answers
        if let data = try? JSONEncoder().encode(session.answers) {
            sessionSD.answersData = data
        }
        
        return sessionSD
    }
}
