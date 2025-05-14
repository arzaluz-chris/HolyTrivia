// CategoriesViewModel.swift
import Foundation
import SwiftUI
import Combine

class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var categoriesWithQuestions: Set<String> = []
    
    private let persistenceManager = PersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCategories()
    }
    
    func loadCategories() {
        isLoading = true
        
        // Simular carga para dar tiempo al usuario de ver el indicador
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.categories = self.persistenceManager.loadCategories()
            
            if self.categories.isEmpty {
                self.errorMessage = NSLocalizedString("Error cargando categorías", comment: "")
            } else {
                self.errorMessage = nil
                self.checkCategoriesWithQuestions()
            }
            
            self.isLoading = false
        }
    }
    
    // Verificar qué categorías tienen preguntas disponibles
    func checkCategoriesWithQuestions() {
        // Obtener todas las preguntas
        let allQuestions = persistenceManager.loadQuestions()
        
        // Agrupar por categoría para determinar cuáles tienen preguntas
        let questionsByCategory = Dictionary(grouping: allQuestions, by: { $0.category })
        
        // Crear un conjunto de IDs de categorías que tienen preguntas
        var categoriesWithQs = Set<String>()
        
        print("Categorías con preguntas:")
        for (categoryId, questions) in questionsByCategory {
            print("- \(categoryId): \(questions.count) preguntas")
            if !questions.isEmpty {
                categoriesWithQs.insert(categoryId)
            }
        }
        
        // Verificar categorías sin preguntas
        print("Categorías sin preguntas:")
        for category in categories {
            if !categoriesWithQs.contains(category.id) {
                print("- \(category.id): \(category.name)")
            }
        }
        
        // Imprimir estado final para cada categoría
        print("\nESTADO FINAL DE CATEGORÍAS:")
        for category in categories {
            let hasQuestions = categoriesWithQs.contains(category.id)
            print("- \(category.name) (\(category.id)): \(hasQuestions ? "HABILITADA" : "DESHABILITADA (sin preguntas)")")
        }
        
        // Actualizar la propiedad publicada
        DispatchQueue.main.async {
            self.categoriesWithQuestions = categoriesWithQs
        }
    }
    
    // Verificar si una categoría tiene preguntas
    func categoryHasQuestions(categoryId: String) -> Bool {
        // Primero intentamos obtener el estado de nuestro conjunto local
        if categoriesWithQuestions.contains(categoryId) {
            return true
        }
        
        // Si no está en nuestro conjunto, consultamos al PersistenceManager
        // (que debería tener una caché actualizada)
        return persistenceManager.categoryHasQuestions(categoryId)
    }
    
    // Obtener estadísticas para una categoría específica
    func getStatsFor(categoryId: String) -> CategoryStat? {
        let stats = persistenceManager.loadUserStats()
        return stats.categoryStats.first(where: { $0.categoryId == categoryId })
    }
    
    // Verificar si hay alguna categoría que tenga al menos una pregunta respondida
    var hasPlayedAnyCategory: Bool {
        let stats = persistenceManager.loadUserStats()
        return stats.categoryStats.contains(where: { $0.answeredQuestions > 0 })
    }
    
    // Obtener categoría por ID
    func getCategory(by id: String) -> Category? {
        return categories.first(where: { $0.id == id })
    }
}
