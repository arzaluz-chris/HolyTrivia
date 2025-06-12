// Presentation/Screens/Home/HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.large) {
                    // Welcome Header
                    headerSection
                    
                    // Player Stats Card
                    if let player = viewModel.player {
                        PlayerStatsCard(player: player)
                            .padding(.horizontal, theme.spacing.medium)
                    }
                    
                    // Categories Section
                    categoriesSection
                    
                    // Daily Streak Section
                    if let player = viewModel.player {
                        StreakView(player: player)
                            .padding(.horizontal, theme.spacing.medium)
                    }
                }
                .padding(.vertical, theme.spacing.medium)
            }
            .background(theme.colors.background)
            .navigationBarHidden(true)
            .task {
                await viewModel.loadData(appContainer: appContainer)
            }
            .refreshable {
                await viewModel.loadData(appContainer: appContainer)
            }
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xSmall) {
            Text(String(localized: "home.welcome"))
                .font(theme.typography.largeTitle)
                .foregroundColor(theme.colors.textPrimary)
            
            Text(String(localized: "home.choose_category"))
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.spacing.medium)
    }
    
    private var categoriesSection: some View {
        VStack(spacing: theme.spacing.medium) {
            ForEach(Category.allCases) { category in
                NavigationLink(destination: QuizView(category: category)) {
                    CategoryCard(
                        category: category,
                        questionCount: viewModel.categoryQuestionCounts[category] ?? 0,
                        isLoading: viewModel.isLoading
                    )
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding(.horizontal, theme.spacing.medium)
    }
}

// MARK: - Subviews
struct PlayerStatsCard: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                    Text("Level \(player.level)")
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(String(localized: "home.current_xp"))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.gold)
            }
            
            // XP Progress Bar
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                HStack {
                    Text("\(player.totalXP)")
                        .font(AppTheme.Typography.footnote.bold())
                        .foregroundColor(AppTheme.Colors.gold)
                    
                    Spacer()
                    
                    Text("\(player.xpForNextLevel)")
                        .font(AppTheme.Typography.footnote)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.gold.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.gold)
                            .frame(width: geometry.size.width * player.levelProgress, height: 8)
                            .animation(AppTheme.Animation.standard, value: player.levelProgress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(AppTheme.Spacing.large)
        .cardStyle()
    }
}

struct CategoryCard: View {
    let category: Category
    let questionCount: Int
    let isLoading: Bool
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            // Icon
            Text(category.icon)
                .font(.system(size: 36))
                .frame(width: 60, height: 60)
                .background(Color(category.themeColor).opacity(0.1))
                .cornerRadius(AppTheme.CornerRadius.medium)
            
            // Text Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxSmall) {
                Text(category.displayName)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if isLoading {
                    Text("Loading...")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                } else {
                    Text("\(questionCount) questions")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.card)
        .shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: 0,
            y: AppTheme.Shadow.card.y
        )
    }
}

struct StreakView: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            HStack {
                Text(String(localized: "home.daily_streak"))
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                if player.currentStreak > 0 {
                    HStack(spacing: AppTheme.Spacing.xxSmall) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(player.currentStreak)")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Week view
            HStack(spacing: AppTheme.Spacing.xSmall) {
                ForEach(StreakTracker.getWeekStreakStatus(
                    lastPlayedDate: player.lastPlayedDate,
                    currentStreak: player.currentStreak
                ), id: \.date) { day in
                    DayCircle(day: day)
                }
            }
        }
        .padding(AppTheme.Spacing.large)
        .cardStyle()
    }
}

struct DayCircle: View {
    let day: DayStatus
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxxSmall) {
            Circle()
                .fill(Color(day.displayState.backgroundColor))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(day.dayName.prefix(1)))
                        .font(AppTheme.Typography.caption.bold())
                        .foregroundColor(Color(day.displayState.textColor))
                )
            
            if day.isToday {
                Circle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppContainer())
}
