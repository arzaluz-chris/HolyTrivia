// PersistenceManager.swift
import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userStatsKey = "userStats"
    private let quizHistoryKey = "quizHistory"
    private let categoriesWithQuestionsKey = "categoriesWithQuestions"
    
    private var cachedQuestions: [Question]?
    private var cachedCategories: [Category]?
    private var cachedCategoriesWithQuestions: Set<String> = []
    
    private init() {
        // Cargar información sobre categorías con preguntas
        loadCategoriesWithQuestions()
    }
    
    // Método para verificar archivos JSON disponibles
    func checkAvailableQuestionFiles() {
        print("VERIFICANDO ARCHIVOS DE PREGUNTAS:")
        
        // Listar todos los archivos en el bundle para depuración
        if let resourceURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
            print("Archivos disponibles en el bundle:")
            for url in resourceURLs {
                print("- \(url.lastPathComponent)")
            }
        }
        
        // Verificar el archivo de español explícitamente
        let filename = "questions_es.json"
        
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
                
                // Imprimir categorías y preguntas por categoría
                print("CATEGORÍAS EN \(filename):")
                for category in questionsData.categories {
                    print("- \(category.id): \(category.name)")
                }
                
                print("PREGUNTAS POR CATEGORÍA EN \(filename):")
                let questionsByCategory = Dictionary(grouping: questionsData.questions, by: { $0.category })
                for (category, questions) in questionsByCategory {
                    print("- \(category): \(questions.count) preguntas")
                }
                
                // Actualizar la información de categorías con preguntas
                updateCategoriesWithQuestions(from: questionsData)
                
            } catch {
                print("Error al leer o decodificar \(filename): \(error)")
            }
        } else {
            print("ERROR: Archivo no encontrado: \(filename) - Verificando rutas alternativas")
            
            // Verificar si existe sin extensión
            if let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
                print("Archivo encontrado con otra estructura: \(filename)")
            } else {
                print("ERROR CRÍTICO: Archivo no encontrado en ninguna variante: \(filename)")
            }
        }
    }
    
    // Actualizar información sobre categorías con preguntas
    private func updateCategoriesWithQuestions(from data: QuestionData) {
        let categories = data.categories
        let questions = data.questions
        
        // Agrupar preguntas por categoría
        let questionsByCategory = Dictionary(grouping: questions, by: { $0.category })
        
        // Crear conjunto de IDs de categorías con preguntas
        var categoriesWithQs = Set<String>()
        
        for category in categories {
            let categoryQuestions = questionsByCategory[category.id] ?? []
            if !categoryQuestions.isEmpty {
                categoriesWithQs.insert(category.id)
            }
        }
        
        // Guardar en caché y persistencia
        self.cachedCategoriesWithQuestions = categoriesWithQs
        saveCategoriesWithQuestions(categoriesWithQs)
        
        print("\nCATEGORIAS CON PREGUNTAS ACTUALIZADAS:")
        for categoryId in categoriesWithQs {
            print("- \(categoryId)")
        }
    }
    
    // Actualizar una categoría específica
    func updateCategoryWithQuestions(categoryId: String, hasQuestions: Bool) {
        var categories = cachedCategoriesWithQuestions
        
        if hasQuestions {
            categories.insert(categoryId)
        } else {
            categories.remove(categoryId)
        }
        
        cachedCategoriesWithQuestions = categories
        saveCategoriesWithQuestions(categories)
    }
    
    // Verificar si una categoría tiene preguntas
    func categoryHasQuestions(_ categoryId: String) -> Bool {
        // Verificar en caché
        if cachedCategoriesWithQuestions.contains(categoryId) {
            return true
        }
        
        // Si no está en caché, verificar directamente
        let count = getTotalQuestionsCountFor(categoryId: categoryId)
        let hasQuestions = count > 0
        
        // Actualizar caché si encontramos preguntas
        if hasQuestions {
            updateCategoryWithQuestions(categoryId: categoryId, hasQuestions: true)
        }
        
        return hasQuestions
    }
    
    // Guardar información de categorías con preguntas
    private func saveCategoriesWithQuestions(_ categories: Set<String>) {
        if let encodedData = try? JSONEncoder().encode(Array(categories)) {
            UserDefaults.standard.set(encodedData, forKey: categoriesWithQuestionsKey)
        }
    }
    
    // Cargar información de categorías con preguntas
    private func loadCategoriesWithQuestions() {
        if let savedData = UserDefaults.standard.data(forKey: categoriesWithQuestionsKey),
           let loadedCategories = try? JSONDecoder().decode([String].self, from: savedData) {
            cachedCategoriesWithQuestions = Set(loadedCategories)
        } else {
            cachedCategoriesWithQuestions = []
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
    func getTotalQuestionsCountFor(categoryId: String) -> Int {
        let allQuestions = loadQuestions()
        let categoryQuestions = allQuestions.filter { $0.category == categoryId }
        return categoryQuestions.count
    }
    
    // Cargar preguntas desde el archivo JSON (con caché)
    func loadQuestions() -> [Question] {
        // Si ya tenemos las preguntas en caché, devolverlas
        if let cached = cachedQuestions {
            return cached
        }
        
        let questions = loadQuestionsFromJSON()
        cachedQuestions = questions
        
        // Actualizar información de categorías con preguntas
        updateCategoriesWithQuestionsFromQuestions(questions)
        
        return questions
    }
    
    // Actualizar información de categorías con preguntas basado en las preguntas disponibles
    private func updateCategoriesWithQuestionsFromQuestions(_ questions: [Question]) {
        // Verificar qué categorías tienen preguntas
        let categories = loadCategories()
        let questionsByCategory = Dictionary(grouping: questions, by: { $0.category })
        
        var categoriesWithQs = Set<String>()
        
        for category in categories {
            let categoryQuestions = questionsByCategory[category.id] ?? []
            if !categoryQuestions.isEmpty {
                categoriesWithQs.insert(category.id)
                print("Categoría \(category.id) tiene \(categoryQuestions.count) preguntas - Marcada como disponible")
            } else {
                print("Categoría \(category.id) no tiene preguntas - Marcada como NO disponible")
            }
        }
        
        // Actualizar caché y persistencia
        cachedCategoriesWithQuestions = categoriesWithQs
        saveCategoriesWithQuestions(categoriesWithQs)
    }
    
    // Implementación real de carga de JSON - SIEMPRE usar questions_es.json
    private func loadQuestionsFromJSON() -> [Question] {
        // Usar explícitamente el archivo en español
        let filename = "questions_es.json"
        
        // Intentar cargar las preguntas desde el archivo JSON en español
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("ERROR: No se pudo encontrar el archivo: \(filename)")
            
            // Probar con otra estructura de archivo como última opción
            if let engUrl = Bundle.main.url(forResource: "questions_es", withExtension: "json") {
                print("Intentando cargar archivo en: \(engUrl.absoluteString)")
                return loadQuestionsFromURL(engUrl)
            }
            
            print("ERROR CRÍTICO: No se pudo encontrar ningún archivo de preguntas")
            return []
        }
        
        print("Cargando preguntas desde: \(url.absoluteString)")
        return loadQuestionsFromURL(url)
    }
    
    private func loadQuestionsFromURL(_ url: URL) -> [Question] {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questionsData = try decoder.decode(QuestionData.self, from: data)
            
            // También actualizamos las categorías con preguntas aquí
            updateCategoriesWithQuestions(from: questionsData)
            
            print("Cargadas \(questionsData.questions.count) preguntas del archivo JSON")
            return questionsData.questions
        } catch {
            print("Error decodificando preguntas: \(error)")
            return []
        }
    }
    
    // Cargar categorías desde el archivo JSON (con caché)
    func loadCategories() -> [Category] {
        // Si ya tenemos las categorías en caché, devolverlas
        if let cached = cachedCategories {
            return cached
        }
        
        let categories = loadCategoriesFromJSON()
        cachedCategories = categories
        return categories
    }
    
    // Implementación real de carga de JSON - SIEMPRE usar questions_es.json
    private func loadCategoriesFromJSON() -> [Category] {
        // Usar explícitamente el archivo en español
        let filename = "questions_es.json"
        
        // Intentar cargar las categorías desde el archivo JSON
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("ERROR: No se pudo encontrar el archivo: \(filename)")
            
            // Probar con otra estructura de archivo como última opción
            if let engUrl = Bundle.main.url(forResource: "questions_es", withExtension: "json") {
                print("Intentando cargar archivo en: \(engUrl.absoluteString)")
                return loadCategoriesFromURL(engUrl)
            }
            
            print("ERROR CRÍTICO: No se pudo encontrar ningún archivo de preguntas")
            return []
        }
        
        print("Cargando categorías desde: \(url.absoluteString)")
        return loadCategoriesFromURL(url)
    }
    
    private func loadCategoriesFromURL(_ url: URL) -> [Category] {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questionsData = try decoder.decode(QuestionData.self, from: data)
            
            print("Cargadas \(questionsData.categories.count) categorías del archivo JSON")
            return questionsData.categories
        } catch {
            print("Error decodificando categorías: \(error)")
            return []
        }
    }
    
    // Limpiar caché (útil para pruebas o cambios de idioma)
    func clearCache() {
        cachedQuestions = nil
        cachedCategories = nil
        
        // Eliminar también los datos guardados
        UserDefaults.standard.removeObject(forKey: categoriesWithQuestionsKey)
        
        // Recargar categorías con preguntas desde cero
        loadCategoriesWithQuestions()
    }
}

// Estructura para decodificar el archivo JSON completo
struct QuestionData: Codable {
    var categories: [Category]
    var questions: [Question]
}
