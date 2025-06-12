// Presentation/Screens/Settings/SettingsViewModel.swift

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var player: Player?
    @Published private(set) var isLoading = false
    @Published private(set) var isSyncing = false
    @Published var showingDeleteConfirmation = false
    @Published var showingResetConfirmation = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func loadPlayer(appContainer: AppContainer) async {
        isLoading = true
        
        do {
            player = try await appContainer.playerRepository.getCurrentPlayer()
            isLoading = false
        } catch {
            print("Failed to load player: \(error)")
            isLoading = false
        }
    }
    
    func toggleCloudSync(enabled: Bool, appContainer: AppContainer) async {
        isSyncing = true
        
        do {
            if enabled {
                try await appContainer.cloudSyncManager?.enableSync()
            } else {
                try await appContainer.cloudSyncManager?.disableSync()
            }
            isSyncing = false
        } catch {
            print("Failed to toggle cloud sync: \(error)")
            isSyncing = false
        }
    }
    
    func resetProgress(appContainer: AppContainer) async {
        guard let player = player else { return }
        
        do {
            // Reset player stats
            var resetPlayer = player
            resetPlayer.totalXP = 0
            resetPlayer.level = 1
            resetPlayer.currentStreak = 0
            resetPlayer.longestStreak = 0
            resetPlayer.achievements = []
            resetPlayer.categoryStats = [:]
            
            try await appContainer.playerRepository.updatePlayer(resetPlayer)
            self.player = resetPlayer
            
            // Clear all session results
            // Note: This would need additional repository methods in a real implementation
        } catch {
            print("Failed to reset progress: \(error)")
        }
    }
    
    func deleteAllData(appContainer: AppContainer) async {
        // This would delete all user data
        // Implementation would depend on specific requirements
        #if DEBUG
        await SwiftDataContainer.shared.clearAllData()
        UserDefaultsManager.shared.clearAllData()
        #endif
    }
    
    func exportData() async -> URL? {
        // Future implementation for data export
        // Would create a JSON file with all user data
        return nil
    }
    
    func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/idXXXXXXXXX") {
            UIApplication.shared.open(url)
        }
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://yourcompany.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTermsOfService() {
        if let url = URL(string: "https://yourcompany.com/terms") {
            UIApplication.shared.open(url)
        }
    }
}
