// Domain/Protocols/CloudSyncProtocol.swift

import Foundation

protocol CloudSyncProtocol {
    var isSyncEnabled: Bool { get }
    var isSyncing: Bool { get }
    var lastSyncDate: Date? { get }
    
    func enableSync() async throws
    func disableSync() async throws
    func syncData() async throws
    func resolveConflicts(local: Any, remote: Any) async throws -> Any
}
