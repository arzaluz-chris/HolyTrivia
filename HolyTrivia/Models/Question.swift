// Question.swift
import Foundation

struct Question: Identifiable, Codable {
    var id: String
    var text: String
    var options: [String]
    var correctOption: Int
    var explanation: String
    var imageRef: String?
    var category: String
    var difficulty: Int
    
    // Función de conveniencia para verificar si una respuesta es correcta
    func isCorrect(_ selectedOption: Int) -> Bool {
        return selectedOption == correctOption
    }
}
