// Category.swift
import Foundation
import SwiftUI

struct Category: Identifiable, Codable {
    var id: String
    var name: String
    var icon: String
    
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
        if let uiImage = UIImage(named: icon) {
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
    
    // Para codificación/decodificación
    enum CodingKeys: String, CodingKey {
        case id, name, icon
    }
}
