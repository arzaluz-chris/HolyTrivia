// Data/Repositories/QuestionRepository.swift

import Foundation
import SwiftData

@MainActor
final class QuestionRepository: QuestionRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    func loadQuestions(for category: Category) async throws -> [Question] {
        let descriptor = FetchDescriptor<QuestionSD>(
            predicate: #Predicate { question in
                question.categoryRawValue == category.rawValue
            }
        )
        
        let questionSDs = try modelContext.fetch(descriptor)
        return questionSDs.compactMap { $0.toDomainModel() }
    }
    
    func loadAllQuestions() async throws -> [Question] {
        let descriptor = FetchDescriptor<QuestionSD>()
        let questionSDs = try modelContext.fetch(descriptor)
        return questionSDs.compactMap { $0.toDomainModel() }
    }
    
    func saveQuestion(_ question: Question) async throws {
        // Check if question already exists
        let descriptor = FetchDescriptor<QuestionSD>(
            predicate: #Predicate { q in
                q.id == question.id
            }
        )
        
        if let existingQuestion = try modelContext.fetch(descriptor).first {
            // Update existing question
            existingQuestion.update(from: question)
        } else {
            // Create new question
            let questionSD = QuestionSD.from(question)
            modelContext.insert(questionSD)
        }
        
        try modelContext.save()
    }
    
    func deleteQuestion(_ question: Question) async throws {
        let descriptor = FetchDescriptor<QuestionSD>(
            predicate: #Predicate { q in
                q.id == question.id
            }
        )
        
        if let questionSD = try modelContext.fetch(descriptor).first {
            modelContext.delete(questionSD)
            try modelContext.save()
        }
    }
    
    func getQuestionCount(for category: Category) async throws -> Int {
        let descriptor = FetchDescriptor<QuestionSD>(
            predicate: #Predicate { question in
                question.categoryRawValue == category.rawValue
            }
        )
        
        return try modelContext.fetchCount(descriptor)
    }
}
