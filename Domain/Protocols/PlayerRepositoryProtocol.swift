// Domain/Protocols/PlayerRepositoryProtocol.swift

import Foundation

protocol PlayerRepositoryProtocol {
    func getCurrentPlayer() async throws -> Player?
    func createPlayer(_ player: Player) async throws
    func updatePlayer(_ player: Player) async throws
    func deletePlayer(_ player: Player) async throws
    func updatePlayerStats(with sessionResult: SessionResult) async throws
    func getLeaderboard(limit: Int) async throws -> [Player]
}
