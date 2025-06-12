// Data/Repositories/SessionRepository.swift

import Foundation
import SwiftData

@MainActor
final class SessionRepository: SessionRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    func saveSession(_ session: SessionResult) async throws {
        let sessionSD = SessionResultSD.from(session)
        modelContext.insert(sessionSD)
        try modelContext.save()
    }
    
    func getSessions(for playerId: UUID, limit: Int?) async throws -> [SessionResult] {
        var descriptor = FetchDescriptor<SessionResultSD>(
            predicate: #Predicate { session in
                session.player?.id == playerId
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        
        let sessionSDs = try modelContext.fetch(descriptor)
        return sessionSDs.compactMap { $0.toDomainModel() }
    }
    
    func getSessionsByCategory(_ category: Category, for playerId: UUID) async throws -> [SessionResult] {
        let descriptor = FetchDescriptor<SessionResultSD>(
            predicate: #Predicate { session in
                session.player?.id == playerId &&
                session.categoryRawValue == category.rawValue
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let sessionSDs = try modelContext.fetch(descriptor)
        return sessionSDs.compactMap { $0.toDomainModel() }
    }
    
    func getRecentSessions(days: Int, for playerId: UUID) async throws -> [SessionResult] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<SessionResultSD>(
            predicate: #Predicate { session in
                session.player?.id == playerId &&
                session.date >= startDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let sessionSDs = try modelContext.fetch(descriptor)
        return sessionSDs.compactMap { $0.toDomainModel() }
    }
    
    func deleteSession(_ session: SessionResult) async throws {
        let descriptor = FetchDescriptor<SessionResultSD>(
            predicate: #Predicate { s in
                s.id == session.id
            }
        )
        
        if let sessionSD = try modelContext.fetch(descriptor).first {
            modelContext.delete(sessionSD)
            try modelContext.save()
        }
    }
    
    func getSessionStats(for playerId: UUID) async throws -> SessionStats {
        let sessions = try await getSessions(for: playerId, limit: nil)
        
        let totalSessions = sessions.count
        let totalXPEarned = sessions.reduce(0) { $0 + $1.xpEarned }
        let averageScore = sessions.isEmpty ? 0 : Double(sessions.reduce(0) { $0 + $1.correctCount }) / Double(sessions.count)
        let perfectSessions = sessions.filter { $0.isPerfect }.count
        
        // Find favorite category
        let categoryGroups = Dictionary(grouping: sessions) { $0.category }
        let favoriteCategory = categoryGroups.max(by: { $0.value.count < $1.value.count })?.key
        
        // Calculate best streak from sessions
        let sortedSessions = sessions.sorted(by: { $0.date < $1.date })
        var bestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions {
            if let last = lastDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: last, to: session.date).day ?? 0
                if daysBetween == 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            bestStreak = max(bestStreak, currentStreak)
            lastDate = session.date
        }
        
        return SessionStats(
            totalSessions: totalSessions,
            totalXPEarned: totalXPEarned,
            averageScore: averageScore,
            favoriteCategory: favoriteCategory,
            bestStreak: bestStreak,
            perfectSessions: perfectSessions
        )
    }
}
