// Presentation/Screens/Onboarding/OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.appTheme) private var theme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $viewModel.currentPage) {
                ForEach(viewModel.pages.indices, id: \.self) { index in
                    OnboardingPageView(
                        pageData: viewModel.pages[index],
                        isLastPage: index == viewModel.pages.count - 1,
                        viewModel: viewModel
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Bottom controls
            VStack(spacing: theme.spacing.medium) {
                // Continue/Get Started button
                Button(action: {
                    if viewModel.currentPage == viewModel.totalPages - 1 {
                        Task {
                            await viewModel.completeOnboarding(appContainer: appContainer)
                            hasCompletedOnboarding = true
                        }
                    } else {
                        viewModel.nextPage()
                    }
                }) {
                    Text(viewModel.currentPage == viewModel.totalPages - 1 ? "Get Started" : "Continue")
                        .frame(maxWidth: .infinity)
                        .primaryButton()
                }
                
                // Skip button
                if viewModel.currentPage < viewModel.totalPages - 1 {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .font(theme.typography.subheadline)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.xLarge)
            .padding(.bottom, theme.spacing.xxLarge)
        }
        .background(theme.colors.background)
    }
}

struct OnboardingPageView: View {
    let pageData: OnboardingPageData
    let isLastPage: Bool
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.xLarge) {
                Spacer(minLength: theme.spacing.xxxLarge)
                
                // Icon
                Image(systemName: pageData.icon)
                    .font(.system(size: 100))
                    .foregroundColor(pageData.color)
                    .padding(.bottom, theme.spacing.large)
                
                // Title and description
                VStack(spacing: theme.spacing.medium) {
                    Text(pageData.title)
                        .font(theme.typography.largeTitle)
                        .foregroundColor(theme.colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(pageData.description)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, theme.spacing.large)
                }
                
                // Additional content for specific pages
                if pageData.title.contains("Welcome") {
                    nameInputSection
                } else if pageData.title.contains("Stay Motivated") {
                    notificationToggleSection
                }
                
                Spacer(minLength: theme.spacing.xxxLarge)
            }
            .padding(theme.spacing.large)
        }
    }
    
    private var nameInputSection: some View {
        VStack(spacing: theme.spacing.small) {
            Text("What should we call you?")
                .font(theme.typography.headline)
                .foregroundColor(theme.colors.textPrimary)
            
            TextField("Enter your name", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(theme.typography.body)
                .frame(maxWidth: 300)
        }
        .padding(.top, theme.spacing.xLarge)
    }
    
    private var notificationToggleSection: some View {
        VStack(spacing: theme.spacing.medium) {
            Toggle(isOn: $viewModel.notificationsEnabled) {
                VStack(alignment: .leading, spacing: theme.spacing.xxSmall) {
                    Text("Enable Daily Reminders")
                        .font(theme.typography.headline)
                        .foregroundColor(theme.colors.textPrimary)
                    
                    Text("Get notified to maintain your streak")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: theme.colors.primary))
            .padding(.horizontal, theme.spacing.large)
            .padding(.vertical, theme.spacing.medium)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius.medium)
            .shadow(
                color: theme.shadow.small.color,
                radius: theme.shadow.small.radius
            )
        }
        .padding(.top, theme.spacing.large)
        .padding(.horizontal, theme.spacing.medium)
    }
}
