// CategoriesViewModel.swift
import Foundation
import SwiftUI
import Combine

class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let persistenceManager = PersistenceManager.shared
    
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
                self.errorMessage = NSLocalizedString("Error loading categories", comment: "")
            } else {
                self.errorMessage = nil
            }
            
            self.isLoading = false
        }
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
