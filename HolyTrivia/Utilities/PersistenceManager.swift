// PersistenceManager.swift
import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userStatsKey = "userStats"
    private let quizHistoryKey = "quizHistory"
    
    // Guardar estadísticas del usuario
    func saveUserStats(_ stats: UserStats) {
        if let encodedData = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encodedData, forKey: userStatsKey)
        }
    }
    
    // Cargar estadísticas del usuario
    func loadUserStats() -> UserStats {
        if let savedData = UserDefaults.standard.data(forKey: userStatsKey),
           let loadedStats = try? JSONDecoder().decode(UserStats.self, from: savedData) {
            return loadedStats
        }
        return UserStats.empty
    }
    
    // Guardar historial de juegos
    func saveQuizHistory(_ history: [QuizResult]) {
        if let encodedData = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedData, forKey: quizHistoryKey)
        }
    }
    
    // Cargar historial de juegos
    func loadQuizHistory() -> [QuizResult] {
        if let savedData = UserDefaults.standard.data(forKey: quizHistoryKey),
           let loadedHistory = try? JSONDecoder().decode([QuizResult].self, from: savedData) {
            return loadedHistory
        }
        return []
    }
    
    // Añadir un nuevo resultado al historial
    func addQuizResult(_ result: QuizResult) {
        var history = loadQuizHistory()
        history.append(result)
        saveQuizHistory(history)
        
        // También actualiza las estadísticas del usuario
        updateUserStats(with: result)
    }
    
    // Actualizar estadísticas del usuario con un nuevo resultado
    private func updateUserStats(with result: QuizResult) {
        var stats = loadUserStats()
        
        stats.totalGames += 1
        stats.totalQuestions += result.questionsCount
        stats.totalCorrectAnswers += result.correctAnswers
        stats.lastPlayed = result.date
        
        if result.score > stats.highScore {
            stats.highScore = result.score
        }
        
        // Actualizar o crear estadísticas de categoría
        if let index = stats.categoryStats.firstIndex(where: { $0.categoryId == result.categoryId }) {
            stats.categoryStats[index].answeredQuestions += result.questionsCount
            stats.categoryStats[index].correctAnswers += result.correctAnswers
        } else {
            let categoryStat = CategoryStat(
                id: UUID().uuidString,
                categoryId: result.categoryId,
                answeredQuestions: result.questionsCount,
                correctAnswers: result.correctAnswers,
                totalQuestions: 30 // Valor por defecto, debería actualizarse con valor real
            )
            stats.categoryStats.append(categoryStat)
        }
        
        saveUserStats(stats)
    }
    
    // Cargar preguntas desde el archivo JSON
    func loadQuestions() -> [Question] {
        let locale = Locale.current.languageCode ?? "en"
        let filename = "questions_\(locale).json"
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            print("No se pudo cargar \(filename)")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let questionsData = try decoder.decode(QuestionData.self, from: data)
            return questionsData.questions
        } catch {
            print("Error decodificando preguntas: \(error)")
            return []
        }
    }
    
    // Cargar categorías desde el archivo JSON
    func loadCategories() -> [Category] {
        let locale = Locale.current.languageCode ?? "en"
        let filename = "questions_\(locale).json"
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            print("No se pudo cargar \(filename)")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let questionsData = try decoder.decode(QuestionData.self, from: data)
            return questionsData.categories
        } catch {
            print("Error decodificando categorías: \(error)")
            return []
        }
    }
}

// Estructura para decodificar el archivo JSON completo
struct QuestionData: Codable {
    var categories: [Category]
    var questions: [Question]
}
