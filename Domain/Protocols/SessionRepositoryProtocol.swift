// Domain/Protocols/SessionRepositoryProtocol.swift

import Foundation

protocol SessionRepositoryProtocol {
    func saveSession(_ session: SessionResult) async throws
    func getSessions(for player: UUID, limit: Int?) async throws -> [SessionResult]
    func getSessionsByCategory(_ category: Category, for player: UUID) async throws -> [SessionResult]
    func getRecentSessions(days: Int, for player: UUID) async throws -> [SessionResult]
    func deleteSession(_ session: SessionResult) async throws
    func getSessionStats(for player: UUID) async throws -> SessionStats
}

struct SessionStats {
    let totalSessions: Int
    let totalXPEarned: Int
    let averageScore: Double
    let favoriteCategory: Category?
    let bestStreak: Int
    let perfectSessions: Int
}
