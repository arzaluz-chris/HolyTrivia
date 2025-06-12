// Presentation/Screens/Leaderboard/LeaderboardView.swift

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.appTheme) private var theme
    @State private var selectedTimeFrame: TimeFrame = .allTime
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Time Frame Picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding(theme.spacing.medium)
                
                // Leaderboard List
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.players.isEmpty {
                    EmptyStateView(
                        icon: "trophy.fill",
                        title: "No Players Yet",
                        message: "Be the first to set a high score!"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: theme.spacing.small) {
                            // Current Player Rank
                            if let currentPlayer = viewModel.currentPlayer,
                               let rank = viewModel.currentPlayerRank {
                                LeaderboardRow(
                                    player: currentPlayer,
                                    rank: rank,
                                    isCurrentPlayer: true
                                )
                                .padding(.horizontal, theme.spacing.medium)
                                
                                Divider()
                                    .padding(.horizontal, theme.spacing.medium)
                            }
                            
                            // Top Players
                            ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                                LeaderboardRow(
                                    player: player,
                                    rank: index + 1,
                                    isCurrentPlayer: player.id == viewModel.currentPlayer?.id
                                )
                                .padding(.horizontal, theme.spacing.medium)
                            }
                        }
                        .padding(.vertical, theme.spacing.medium)
                    }
                }
            }
            .background(theme.colors.background)
            .navigationTitle(String(localized: "leaderboard.title"))
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadLeaderboard(appContainer: appContainer)
            }
            .onChange(of: selectedTimeFrame) { _, _ in
                Task {
                    await viewModel.loadLeaderboard(appContainer: appContainer)
                }
            }
            .refreshable {
                await viewModel.loadLeaderboard(appContainer: appContainer)
            }
        }
    }
}

struct LeaderboardRow: View {
    let player: Player
    let rank: Int
    let isCurrentPlayer: Bool
    
    @Environment(\.appTheme) private var theme
    
    var rankColor: Color {
        switch rank {
        case 1:
            return theme.colors.gold
        case 2:
            return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3:
            return Color(red: 0.80, green: 0.50, blue: 0.20) // Bronze
        default:
            return theme.colors.textSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: theme.spacing.medium) {
            // Rank
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 40, height: 40)
                }
                
                Text("\(rank)")
                    .font(rank <= 3 ? theme.typography.headline : theme.typography.body)
                    .foregroundColor(rank <= 3 ? .white : theme.colors.textSecondary)
                    .frame(width: 40, height: 40)
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: theme.spacing.xxxSmall) {
                HStack {
                    Text(player.username.isEmpty ? "Player \(rank)" : player.username)
                        .font(theme.typography.headline)
                        .foregroundColor(theme.colors.textPrimary)
                    
                    if isCurrentPlayer {
                        Text("(You)")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.primary)
                    }
                }
                
                Text("Level \(player.level) • \(categoryText(for: player))")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
            
            // XP
            VStack(alignment: .trailing, spacing: theme.spacing.xxxSmall) {
                Text("\(player.totalXP)")
                    .font(theme.typography.headline.monospacedDigit())
                    .foregroundColor(theme.colors.gold)
                
                Text("XP")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .padding(theme.spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .fill(isCurrentPlayer ? theme.colors.primary.opacity(0.1) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .stroke(isCurrentPlayer ? theme.colors.primary : Color.clear, lineWidth: 2)
        )
    }
    
    private func categoryText(for player: Player) -> String {
        if let favorite = player.favoriteCategory {
            return favorite.displayName
        }
        return "\(player.totalGamesPlayed) games"
    }
}
