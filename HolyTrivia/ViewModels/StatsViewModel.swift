// StatsViewModel.swift
import Foundation
import Combine

class StatsViewModel: ObservableObject {
    @Published var userStats: UserStats = UserStats.empty
    @Published var quizHistory: [QuizResult] = []
    @Published var categories: [Category] = []
    
    private let persistenceManager = PersistenceManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        userStats = persistenceManager.loadUserStats()
        quizHistory = persistenceManager.loadQuizHistory().sorted(by: { $0.date > $1.date })
        categories = persistenceManager.loadCategories()
    }
    
    // Get category name by ID
    func getCategoryName(forId id: String) -> String {
        return categories.first(where: { $0.id == id })?.name ?? id
    }
    
    // Get stats for charts or tables
    func getCategoryStats() -> [(category: Category, stat: CategoryStat)] {
        var result: [(category: Category, stat: CategoryStat)] = []
        
        for stat in userStats.categoryStats {
            if let category = categories.first(where: { $0.id == stat.categoryId }) {
                result.append((category: category, stat: stat))
            }
        }
        
        return result.sorted(by: { $0.stat.accuracy > $1.stat.accuracy })
    }
    
    // Get best results by category
    func getBestResultsByCategory() -> [String: QuizResult] {
        var bestResults: [String: QuizResult] = [:]
        
        for result in quizHistory {
            if let existingBest = bestResults[result.categoryId] {
                if result.score > existingBest.score {
                    bestResults[result.categoryId] = result
                }
            } else {
                bestResults[result.categoryId] = result
            }
        }
        
        return bestResults
    }
    
    // Calculate user "mastery" level (0-5 stars)
    func calculateMasteryLevel() -> Int {
        let accuracy = userStats.overallAccuracy
        
        switch accuracy {
        case 0..<0.2: return 1
        case 0.2..<0.4: return 2
        case 0.4..<0.6: return 3
        case 0.6..<0.8: return 4
        case 0.8...1.0: return 5
        default: return 0
        }
    }
    
    // Reset all stats
    func resetAllStats() {
        persistenceManager.saveUserStats(UserStats.empty)
        persistenceManager.saveQuizHistory([])
        loadData()
    }
    
    // Get formatted date of last game
    var lastPlayedFormatted: String {
        guard let lastPlayed = userStats.lastPlayed else {
            return NSLocalizedString("Never played", comment: "")
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastPlayed)
    }
}
