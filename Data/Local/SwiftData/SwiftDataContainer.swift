// Data/Local/SwiftData/SwiftDataContainer.swift

import SwiftData
import SwiftUI

final class SwiftDataContainer {
    static let shared = SwiftDataContainer()
    
    let modelContainer: ModelContainer
    
    private init() {
        do {
            let schema = Schema([
                QuestionSD.self,
                PlayerSD.self,
                SessionResultSD.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.yourcompany.holytrivia")
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Migration Support
    func performMigrationIfNeeded() async {
        // Future implementation for data migration between versions
        let context = modelContainer.mainContext
        
        // Check if this is first launch
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "hasPerformedInitialSetup") == false
        
        if isFirstLaunch {
            await performInitialSetup(context: context)
            UserDefaults.standard.set(true, forKey: "hasPerformedInitialSetup")
        }
    }
    
    private func performInitialSetup(context: ModelContext) async {
        // Create default player if needed
        do {
            let descriptor = FetchDescriptor<PlayerSD>()
            let players = try context.fetch(descriptor)
            
            if players.isEmpty {
                let defaultPlayer = PlayerSD(username: "Player")
                context.insert(defaultPlayer)
                try context.save()
            }
        } catch {
            print("Failed to perform initial setup: \(error)")
        }
    }
    
    // MARK: - Debug Helpers
    #if DEBUG
    func clearAllData() async {
        let context = modelContainer.mainContext
        
        do {
            // Delete all questions
            try context.delete(model: QuestionSD.self)
            
            // Delete all players
            try context.delete(model: PlayerSD.self)
            
            // Delete all sessions
            try context.delete(model: SessionResultSD.self)
            
            try context.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
    #endif
}
