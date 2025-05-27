// Question.swift
import Foundation

struct Question: Identifiable, Codable {
    var id: String
    var text: String
    var options: [String]
    var correctOption: Int
    var explanation: String
    var imageRef: String? // Ya es opcional
    var category: String
    var difficulty: Int
    
    // Función de conveniencia para verificar si una respuesta es correcta
    func isCorrect(_ selectedOption: Int) -> Bool {
        return selectedOption == correctOption
    }
    
    // Añadir codificación personalizada para manejar posibles problemas de formato
    enum CodingKeys: String, CodingKey {
        case id, text, options, correctOption, explanation, imageRef, category, difficulty
    }
    
    init(id: String, text: String, options: [String], correctOption: Int, explanation: String, imageRef: String?, category: String, difficulty: Int) {
        self.id = id
        self.text = text
        self.options = options
        self.correctOption = correctOption
        self.explanation = explanation
        self.imageRef = imageRef
        self.category = category
        self.difficulty = difficulty
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.options = try container.decode([String].self, forKey: .options)
        self.correctOption = try container.decode(Int.self, forKey: .correctOption)
        
        // Manejar posible ausencia de explanation
        if container.contains(.explanation) {
            self.explanation = try container.decode(String.self, forKey: .explanation)
        } else {
            self.explanation = "No explanation available."
        }
        
        // imageRef ya es opcional, usar decodeIfPresent
        self.imageRef = try container.decodeIfPresent(String.self, forKey: .imageRef)
        self.category = try container.decode(String.self, forKey: .category)
        
        // Manejar posible ausencia de difficulty
        if container.contains(.difficulty) {
            self.difficulty = try container.decode(Int.self, forKey: .difficulty)
        } else {
            self.difficulty = 1
        }
    }
}
