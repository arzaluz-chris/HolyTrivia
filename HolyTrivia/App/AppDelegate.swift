// AppDelegate.swift
import UIKit
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Forzar español como idioma
        forceSpanishLanguage()
        
        // Limpiar caché y UserDefaults
        clearAppCache()
        
        // Configurar audio
        setupAudio()
        
        // Verificar y precarga datos
        precacheCategoriesAndQuestions()
        
        // Redirigir logs para depuración
        redirectLogsToFile()
        
        return true
    }
    
    private func forceSpanishLanguage() {
        // Establecer español como idioma forzado
        UserDefaults.standard.set(["es"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        print("Idioma forzado a español")
    }
    
    private func clearAppCache() {
        // Limpiar caché de PersistenceManager
        PersistenceManager.shared.clearCache()
        
        print("Caché de aplicación limpiada")
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func precacheCategoriesAndQuestions() {
        // Verificar archivos JSON y precargar datos
        PersistenceManager.shared.checkAvailableQuestionFiles()
        
        // Precarga de categorías y verificación de preguntas disponibles
        let persistenceManager = PersistenceManager.shared
        let categories = persistenceManager.loadCategories()
        let questions = persistenceManager.loadQuestions()
        
        print("\n=== RESUMEN DE DATOS PRECARGADOS ===")
        print("Total categorías: \(categories.count)")
        print("Total preguntas: \(questions.count)")
        
        // Agrupar preguntas por categoría
        let questionsByCategory = Dictionary(grouping: questions, by: { $0.category })
        
        // Comprobar categorías con y sin preguntas
        print("\nCATEGORÍAS Y PREGUNTAS DISPONIBLES:")
        for category in categories {
            let categoryQuestions = questionsByCategory[category.id] ?? []
            print("- \(category.name) (\(category.id)): \(categoryQuestions.count) preguntas")
            
            // Guardar esta información en el PersistenceManager
            persistenceManager.updateCategoryWithQuestions(categoryId: category.id, hasQuestions: !categoryQuestions.isEmpty)
        }
        
        // Verificar categorías sin preguntas
        let categoriesWithoutQuestions = categories.filter { category in
            let count = questionsByCategory[category.id]?.count ?? 0
            return count == 0
        }
        
        print("\nCATEGORÍAS SIN PREGUNTAS (\(categoriesWithoutQuestions.count)):")
        for category in categoriesWithoutQuestions {
            print("- \(category.name) (\(category.id))")
        }
        print("===================================\n")
    }
    
    private func redirectLogsToFile() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let logPath = documentsPath.appending("/holytrivia.log")
        
        print("Redirigiendo logs a: \(logPath)")
        
        // Intentar abrir el archivo para escritura
        freopen(logPath.cString(using: .ascii), "a+", stderr)
    }
}
