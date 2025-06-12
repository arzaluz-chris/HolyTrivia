// Presentation/Screens/Results/ResultsView.swift

import SwiftUI

struct ResultsView: View {
    let sessionResult: SessionResult
    let category: Category
    
    @StateObject private var viewModel = ResultsViewModel()
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingShareSheet = false
    @State private var showingAchievements = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.xLarge) {
                // Celebration Header
                celebrationHeader
                
                // Score Card
                ScoreCard(sessionResult: sessionResult)
                    .padding(.horizontal, theme.spacing.medium)
                
                // XP Progress
                if let xpBreakdown = viewModel.xpBreakdown {
                    XPProgressView(
                        xpBreakdown: xpBreakdown,
                        player: viewModel.player
                    )
                    .padding(.horizontal, theme.spacing.medium)
                }
                
                // Achievements
                if !viewModel.unlockedAchievements.isEmpty {
                    achievementsSection
                }
                
                // Action Buttons
                actionButtons
            }
            .padding(.vertical, theme.spacing.large)
        }
        .background(theme.colors.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(theme.typography.headline)
            }
        }
        .task {
            await viewModel.processResults(
                sessionResult: sessionResult,
                appContainer: appContainer
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(text: sessionResult.shareText)
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsListView(achievements: viewModel.unlockedAchievements)
                .presentationDetents([.medium])
        }
    }
    
    private var celebrationHeader: some View {
        VStack(spacing: theme.spacing.small) {
            Text(getEmoji())
                .font(.system(size: 80))
            
            Text(String(localized: "results.great_job"))
                .font(theme.typography.largeTitle)
                .foregroundColor(theme.colors.textPrimary)
            
            Text(String(localized: "results.you_scored",
                       defaultValue: "You scored \(sessionResult.correctCount)/\(sessionResult.totalQuestions) correct answers"))
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
        }
        .multilineTextAlignment(.center)
    }
    
    private var achievementsSection: some View {
        VStack(spacing: theme.spacing.medium) {
            HStack {
                Text(String(localized: "achievement.unlocked"))
                    .font(theme.typography.headline)
                
                Spacer()
                
                Button("View All") {
                    showingAchievements = true
                }
                .font(theme.typography.subheadline)
            }
            
            ForEach(viewModel.unlockedAchievements.prefix(2)) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
        .padding(.horizontal, theme.spacing.medium)
    }
    
    private var actionButtons: some View {
        VStack(spacing: theme.spacing.medium) {
            NavigationLink(destination: QuizView(category: category)) {
                Text(String(localized: "results.play_again"))
                    .frame(maxWidth: .infinity)
                    .primaryButton()
            }
            
            Button(action: { dismiss() }) {
                Text(String(localized: "results.choose_category"))
                    .frame(maxWidth: .infinity)
                    .secondaryButton()
            }
            
            Button(action: { showingShareSheet = true }) {
                HStack {
                    Text(String(localized: "results.share"))
                    Image(systemName: "square.and.arrow.up")
                }
                .font(theme.typography.callout)
                .foregroundColor(theme.colors.primary)
            }
        }
        .padding(.horizontal, theme.spacing.medium)
    }
    
    private func getEmoji() -> String {
        switch sessionResult.accuracy {
        case 1.0:
            return "🎉"
        case 0.8..<1.0:
            return "🌟"
        case 0.6..<0.8:
            return "👏"
        case 0.4..<0.6:
            return "💪"
        default:
            return "🤗"
        }
    }
}

// MARK: - Subviews
struct ScoreCard: View {
    let sessionResult: SessionResult
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.large) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(theme.colors.primary.opacity(0.2), lineWidth: 12)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: sessionResult.accuracy)
                    .stroke(theme.colors.primary, lineWidth: 12)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(theme.animation.slow, value: sessionResult.accuracy)
                
                VStack {
                    Text("\(sessionResult.correctCount)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(theme.colors.primary)
                    
                    Text("/ \(sessionResult.totalQuestions)")
                        .font(theme.typography.headline)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            
            // Stats Grid
            HStack(spacing: theme.spacing.xLarge) {
                StatItem(
                    title: "Accuracy",
                    value: String(format: "%.0f%%", sessionResult.accuracy * 100)
                )
                
                StatItem(
                    title: "Time",
                    value: sessionResult.formattedTime
                )
                
                StatItem(
                    title: "Category",
                    value: sessionResult.category.displayName
                )
            }
        }
        .padding(theme.spacing.xLarge)
        .cardStyle()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.xxSmall) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
            
            Text(value)
                .font(theme.typography.headline)
                .foregroundColor(theme.colors.textPrimary)
        }
    }
}

struct XPProgressView: View {
    let xpBreakdown: XPCalculator.XPBreakdown
    let player: Player?
    @Environment(\.appTheme) private var theme
    @State private var showBreakdown = false
    
    var body: some View {
        VStack(spacing: theme.spacing.medium) {
            // XP Earned
            HStack {
                Text(String(localized: "results.xp_earned"))
                    .font(theme.typography.headline)
                
                Spacer()
                
                Text("+\(xpBreakdown.total)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(theme.colors.gold)
            }
            
            // Breakdown (if has bonuses)
            if xpBreakdown.hasAnyBonus {
                VStack(alignment: .leading, spacing: theme.spacing.xSmall) {
                    XPBreakdownRow(label: "Base XP", value: xpBreakdown.baseXP)
                    
                    if xpBreakdown.streakBonus > 0 {
                        XPBreakdownRow(
                            label: "Streak Bonus",
                            value: xpBreakdown.streakBonus,
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    
                    if xpBreakdown.perfectBonus > 0 {
                        XPBreakdownRow(
                            label: String(localized: "results.perfect_bonus",
                                        defaultValue: "Perfect Score Bonus! +\(xpBreakdown.perfectBonus)"),
                            value: xpBreakdown.perfectBonus,
                            icon: "star.fill",
                            color: theme.colors.gold
                        )
                    }
                    
                    if xpBreakdown.speedBonus > 0 {
                        XPBreakdownRow(
                            label: "Speed Bonus",
                            value: xpBreakdown.speedBonus,
                            icon: "bolt.fill",
                            color: theme.colors.primary
                        )
                    }
                }
                .padding(.top, theme.spacing.small)
            }
            
            // Level Progress
            if let player = player {
                Divider()
                
                VStack(alignment: .leading, spacing: theme.spacing.xSmall) {
                    HStack {
                        Text("Level \(player.level)")
                            .font(theme.typography.subheadline)
                        
                        Spacer()
                        
                        Text("\(player.totalXP) / \(player.xpForNextLevel)")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.colors.gold.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.colors.gold)
                                .frame(width: geometry.size.width * player.levelProgress, height: 8)
                                .animation(theme.animation.standard, value: player.levelProgress)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(theme.spacing.large)
        .cardStyle()
    }
}

struct XPBreakdownRow: View {
    let label: String
    let value: Int
    var icon: String? = nil
    var color: Color = AppTheme.Colors.textSecondary
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(theme.typography.footnote)
                .foregroundColor(theme.colors.textSecondary)
            
            Spacer()
            
            Text("+\(value)")
                .font(theme.typography.footnote.bold())
                .foregroundColor(color)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        HStack(spacing: theme.spacing.medium) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(theme.colors.gold)
                .frame(width: 44, height: 44)
                .background(theme.colors.gold.opacity(0.1))
                .cornerRadius(theme.cornerRadius.small)
            
            VStack(alignment: .leading, spacing: theme.spacing.xxxSmall) {
                Text(achievement.name)
                    .font(theme.typography.headline)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text(achievement.description)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
            
            Text("+\(achievement.xpReward)")
                .font(theme.typography.footnote.bold())
                .foregroundColor(theme.colors.gold)
        }
        .padding(theme.spacing.medium)
        .background(theme.colors.gold.opacity(0.05))
        .cornerRadius(theme.cornerRadius.medium)
    }
}

struct AchievementsListView: View {
    let achievements: [Achievement]
    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.small) {
                    ForEach(achievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
                .padding(theme.spacing.medium)
            }
            .background(theme.colors.background)
            .navigationTitle(String(localized: "achievement.unlocked"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
