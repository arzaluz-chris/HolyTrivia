// Data/Local/SwiftData/SwiftDataModels/PlayerSD.swift

import Foundation
import SwiftData

@Model
final class PlayerSD {
    @Attribute(.unique) var id: UUID
    var username: String
    var totalXP: Int
    var level: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastPlayedDate: Date?
    var achievements: [String]
    var categoryStatsData: Data? // Encoded [Category: CategoryStat]
    var createdDate: Date
    var preferredCategoriesData: Data? // Encoded [Category]
    
    @Relationship(deleteRule: .cascade) var sessions: [SessionResultSD]?
    
    init(
        id: UUID = UUID(),
        username: String = "",
        totalXP: Int = 0,
        level: Int = 1,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastPlayedDate: Date? = nil,
        achievements: [String] = [],
        createdDate: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.totalXP = totalXP
        self.level = level
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastPlayedDate = lastPlayedDate
        self.achievements = achievements
        self.createdDate = createdDate
        self.sessions = []
    }
    
    // Convert to domain model
    func toDomainModel() -> Player {
        var categoryStats: [Category: CategoryStat] = [:]
        if let data = categoryStatsData {
            categoryStats = (try? JSONDecoder().decode([Category: CategoryStat].self, from: data)) ?? [:]
        }
        
        var preferredCategories: [Category] = []
        if let data = preferredCategoriesData {
            preferredCategories = (try? JSONDecoder().decode([Category].self, from: data)) ?? []
        }
        
        return Player(
            id: id,
            username: username,
            totalXP: totalXP,
            level: level,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastPlayedDate: lastPlayedDate,
            achievements: Set(achievements),
            categoryStats: categoryStats,
            createdDate: createdDate,
            preferredCategories: preferredCategories
        )
    }
    
    // Update from domain model
    func update(from player: Player) {
        self.username = player.username
        self.totalXP = player.totalXP
        self.level = player.level
        self.currentStreak = player.currentStreak
        self.longestStreak = player.longestStreak
        self.lastPlayedDate = player.lastPlayedDate
        self.achievements = Array(player.achievements)
        
        // Encode category stats
        if let data = try? JSONEncoder().encode(player.categoryStats) {
            self.categoryStatsData = data
        }
        
        // Encode preferred categories
        if let data = try? JSONEncoder().encode(player.preferredCategories) {
            self.preferredCategoriesData = data
        }
    }
    
    // Create from domain model
    static func from(_ player: Player) -> PlayerSD {
        let playerSD = PlayerSD(
            id: player.id,
            username: player.username,
            totalXP: player.totalXP,
            level: player.level,
            currentStreak: player.currentStreak,
            longestStreak: player.longestStreak,
            lastPlayedDate: player.lastPlayedDate,
            achievements: Array(player.achievements),
            createdDate: player.createdDate
        )
        
        // Encode category stats
        if let data = try? JSONEncoder().encode(player.categoryStats) {
            playerSD.categoryStatsData = data
        }
        
        // Encode preferred categories
        if let data = try? JSONEncoder().encode(player.preferredCategories) {
            playerSD.preferredCategoriesData = data
        }
        
        return playerSD
    }
}
