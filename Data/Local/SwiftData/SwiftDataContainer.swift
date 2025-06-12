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
        await MainActor.run {
            let context = modelContainer.mainContext

            // Check if this is first launch
            let isFirstLaunch = UserDefaults.standard.bool(forKey: "hasPerformedInitialSetup") == false

            if isFirstLaunch {
                performInitialSetup(context: context)
                UserDefaults.standard.set(true, forKey: "hasPerformedInitialSetup")
            }
        }
    }
    
    @MainActor private func performInitialSetup(context: ModelContext) {
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
        await MainActor.run {
            let context = modelContainer.mainContext
            
            do {
                try context.delete(model: QuestionSD.self)
                try context.delete(model: PlayerSD.self)
                try context.delete(model: SessionResultSD.self)
                try context.save()
            } catch {
                print("Failed to clear data: \(error)")
            }
        }
    }
    #endif
}
