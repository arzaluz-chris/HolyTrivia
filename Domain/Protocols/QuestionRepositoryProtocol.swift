// Domain/Protocols/QuestionRepositoryProtocol.swift

import Foundation

protocol QuestionRepositoryProtocol {
    func loadQuestions(for category: Category) async throws -> [Question]
    func loadAllQuestions() async throws -> [Question]
    func saveQuestion(_ question: Question) async throws
    func deleteQuestion(_ question: Question) async throws
    func getQuestionCount(for category: Category) async throws -> Int
}
