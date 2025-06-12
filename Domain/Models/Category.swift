// Domain/Models/Category.swift

import Foundation

enum Category: String, Codable, CaseIterable, Identifiable {
    case oldTestament = "old_testament"
    case newTestament = "new_testament"
    case gospels = "gospels"
    case characters = "characters"
    case wisdomProphecy = "wisdom_prophecy"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .oldTestament:
            return String(localized: "category.old_testament")
        case .newTestament:
            return String(localized: "category.new_testament")
        case .gospels:
            return String(localized: "category.gospels")
        case .characters:
            return String(localized: "category.characters")
        case .wisdomProphecy:
            return String(localized: "category.wisdom_prophecy")
        }
    }
    
    var icon: String {
        switch self {
        case .oldTestament:
            return "📜"
        case .newTestament:
            return "📖"
        case .gospels:
            return "✝️"
        case .characters:
            return "👥"
        case .wisdomProphecy:
            return "🕊️"
        }
    }
    
    var description: String {
        switch self {
        case .oldTestament:
            return String(localized: "category.old_testament.description")
        case .newTestament:
            return String(localized: "category.new_testament.description")
        case .gospels:
            return String(localized: "category.gospels.description")
        case .characters:
            return String(localized: "category.characters.description")
        case .wisdomProphecy:
            return String(localized: "category.wisdom_prophecy.description")
        }
    }
    
    var themeColor: String {
        switch self {
        case .oldTestament:
            return "OldTestamentColor"
        case .newTestament:
            return "NewTestamentColor"
        case .gospels:
            return "GospelsColor"
        case .characters:
            return "CharactersColor"
        case .wisdomProphecy:
            return "WisdomColor"
        }
    }
}
