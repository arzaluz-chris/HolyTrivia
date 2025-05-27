// Category.swift
import Foundation
import SwiftUI

struct Category: Identifiable, Codable {
    var id: String
    var name: String
    var icon: String? // Ahora es opcional
    
    // Propiedades computadas que no se codifican
    var color: Color {
        switch id {
        case "old_testament": return Color("OldTestamentColor")
        case "gospels": return Color("GospelsColor")
        case "new_testament": return Color("NewTestamentColor")
        case "bible_characters": return Color("CharactersColor")
        case "wisdom": return Color("WisdomColor")
        default: return Color.blue
        }
    }
    
    var iconImage: Image {
        if let iconName = icon, let uiImage = UIImage(named: iconName) {
            return Image(uiImage: uiImage)
        }
        return systemIcon
    }
    
    var systemIcon: Image {
        return Image(systemName: systemIconName)
    }
    
    var systemIconName: String {
        switch id {
        case "old_testament": return "scroll"
        case "gospels": return "book"
        case "new_testament": return "doc.text"
        case "bible_characters": return "person.2"
        case "wisdom": return "lightbulb"
        default: return "questionmark.circle"
        }
    }
    
    // Para codificación/decodificación - icon es opcional
    enum CodingKeys: String, CodingKey {
        case id, name, icon
    }
    
    // Decodificación personalizada para manejar icon opcional
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
    }
    
    // Inicializador manual para casos donde se crea programáticamente
    init(id: String, name: String, icon: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}
