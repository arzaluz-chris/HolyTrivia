// PersistenceManager.swift
import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userStatsKey = "userStats"
    private let quizHistoryKey = "quizHistory"
    
    // Método para verificar archivos JSON disponibles
    func checkAvailableQuestionFiles() {
        let locales = ["en", "es"]
        
        for locale in locales {
            let filename = "questions_\(locale).json"
            
            // Verificar si el archivo existe en el bundle
            if let url = Bundle.main.url(forResource: filename, withExtension: nil) {
                print("Archivo encontrado: \(filename)")
                
                do {
                    let data = try Data(contentsOf: url)
                    print("Archivo leído correctamente: \(filename), tamaño: \(data.count) bytes")
                    
                    // Intentar decodificar para verificar formato
                    let decoder = JSONDecoder()
                    let questionsData = try decoder.decode(QuestionData.self, from: data)
                    print("Archivo decodificado correctamente: \(filename)")
                    print("- Categorías: \(questionsData.categories.count)")
                    print("- Preguntas: \(questionsData.questions.count)")
                } catch {
                    print("Error al leer o decodificar \(filename): \(error)")
                }
            } else {
                print("Archivo no encontrado: \(filename)")
                
                // Verificar si existe sin extensión
                if let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
                    print("Archivo encontrado con otra estructura: \(filename)")
                } else {
                    print("Archivo no encontrado en ninguna variante: \(filename)")
                }
            }
        }
        
        // Listar todos los archivos en el bundle para depuración
        if let resourceURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
            print("Archivos en el bundle:")
            for url in resourceURLs {
                print("- \(url.lastPathComponent)")
            }
        }
    }
    
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
            // Obtener total de preguntas para esta categoría
            let totalQuestions = getTotalQuestionsCountFor(categoryId: result.categoryId)
            
            let categoryStat = CategoryStat(
                id: UUID().uuidString,
                categoryId: result.categoryId,
                answeredQuestions: result.questionsCount,
                correctAnswers: result.correctAnswers,
                totalQuestions: totalQuestions
            )
            stats.categoryStats.append(categoryStat)
        }
        
        saveUserStats(stats)
    }
    
    // Obtener número total de preguntas disponibles para una categoría
    private func getTotalQuestionsCountFor(categoryId: String) -> Int {
        let allQuestions = loadQuestions()
        let categoryQuestions = allQuestions.filter { $0.category == categoryId }
        return categoryQuestions.count
    }
    
    // Cargar preguntas desde el archivo JSON
    func loadQuestions() -> [Question] {
        let locale = Locale.current.languageCode ?? "en"
        let filename = "questions_\(locale).json"
        
        // Intentar cargar las preguntas desde el archivo JSON correspondiente al idioma
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("No se pudo encontrar el archivo: \(filename)")
            
            // Probar con el archivo en inglés como fallback
            if locale != "en", let engUrl = Bundle.main.url(forResource: "questions_en", withExtension: "json") {
                return loadQuestionsFromURL(engUrl)
            } else if let engUrl = Bundle.main.url(forResource: "questions_en", withExtension: nil) {
                return loadQuestionsFromURL(engUrl)
            }
            
            return []
        }
        
        return loadQuestionsFromURL(url)
    }
    
    private func loadQuestionsFromURL(_ url: URL) -> [Question] {
        do {
            let data = try Data(contentsOf: url)
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
        
        // Intentar cargar las categorías desde el archivo JSON correspondiente al idioma
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("No se pudo encontrar el archivo: \(filename)")
            
            // Probar con el archivo en inglés como fallback
            if locale != "en", let engUrl = Bundle.main.url(forResource: "questions_en", withExtension: "json") {
                return loadCategoriesFromURL(engUrl)
            } else if let engUrl = Bundle.main.url(forResource: "questions_en", withExtension: nil) {
                return loadCategoriesFromURL(engUrl)
            }
            
            return []
        }
        
        return loadCategoriesFromURL(url)
    }
    
    private func loadCategoriesFromURL(_ url: URL) -> [Category] {
        do {
            let data = try Data(contentsOf: url)
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
