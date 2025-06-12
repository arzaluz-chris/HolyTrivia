// Data/Remote/CloudKit/CloudKitManager.swift

import CloudKit
import SwiftUI

@MainActor
final class CloudKitManager: CloudSyncProtocol {
    // MARK: - Properties
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    @AppStorage("cloudSyncEnabled") private var _isSyncEnabled = false
    @Published private(set) var isSyncing = false
    private(set) var lastSyncDate: Date? {
        get { UserDefaults.standard.object(forKey: "lastCloudSyncDate") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lastCloudSyncDate") }
    }
    
    var isSyncEnabled: Bool {
        _isSyncEnabled
    }
    
    // MARK: - Initialization
    init(container: CKContainer) {
        self.container = container
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Public Methods
    func enableSync() async throws {
        // Check account status
        let status = try await container.accountStatus()
        
        switch status {
        case .available:
            _isSyncEnabled = true
            try await syncData()
        case .noAccount:
            throw CloudKitError.noAccount
        case .restricted:
            throw CloudKitError.restricted
        case .couldNotDetermine:
            throw CloudKitError.unknown
        case .temporarilyUnavailable:
            throw CloudKitError.temporarilyUnavailable
        @unknown default:
            throw CloudKitError.unknown
        }
    }
    
    func disableSync() async throws {
        _isSyncEnabled = false
    }
    
    func syncData() async throws {
        guard isSyncEnabled else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // Sync player data
            try await syncPlayerData()
            
            // Sync session results
            try await syncSessionResults()
            
            // Update last sync date
            lastSyncDate = Date()
        } catch {
            print("CloudKit sync failed: \(error)")
            throw error
        }
    }
    
    func resolveConflicts(local: Any, remote: Any) async throws -> Any {
        // Simple conflict resolution: latest wins
        // In a production app, you'd implement more sophisticated conflict resolution
        if let localPlayer = local as? Player,
           let remotePlayer = remote as? Player {
            return localPlayer.totalXP >= remotePlayer.totalXP ? localPlayer : remotePlayer
        }
        
        return local
    }
    
    // MARK: - Private Methods
    private func syncPlayerData() async throws {
        // Implementation would sync player data to CloudKit
        // This is a simplified example
        let query = CKQuery(recordType: "Player", predicate: NSPredicate(value: true))
        
        do {
            let records = try await privateDatabase.records(matching: query)
            // Process records and update local database
        } catch {
            throw CloudKitError.syncFailed(error)
        }
    }
    
    private func syncSessionResults() async throws {
        // Implementation would sync session results to CloudKit
        let query = CKQuery(recordType: "SessionResult", predicate: NSPredicate(value: true))
        
        do {
            let records = try await privateDatabase.records(matching: query)
            // Process records and update local database
        } catch {
            throw CloudKitError.syncFailed(error)
        }
    }
}

// MARK: - CloudKit Errors
enum CloudKitError: LocalizedError {
    case noAccount
    case restricted
    case temporarilyUnavailable
    case unknown
    case syncFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noAccount:
            return "iCloud account required. Please sign in to iCloud in Settings."
        case .restricted:
            return "iCloud access is restricted."
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable. Please try again later."
        case .unknown:
            return "Unknown iCloud error occurred."
        case .syncFailed(let error):
            return "Sync failed: \(error.localizedDescription)"
        }
    }
}
