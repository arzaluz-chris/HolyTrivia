// App/HolyTriviaApp.swift

import SwiftUI
import SwiftData

@main
struct HolyTriviaApp: App {
    @StateObject private var appContainer = AppContainer()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("colorScheme") private var colorScheme: String = "system"
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(appContainer.modelContainer)
                .environmentObject(appContainer)
                .preferredColorScheme(getColorScheme())
                .task {
                    await appContainer.initialize()
                }
        }
    }
    
    private func getColorScheme() -> ColorScheme? {
        switch colorScheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.default, value: hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var appContainer: AppContainer
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(String(localized: "tab.home"), systemImage: "house.fill")
                }
                .tag(0)
            
            LeaderboardView()
                .tabItem {
                    Label(String(localized: "tab.leaderboard"), systemImage: "trophy.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label(String(localized: "tab.settings"), systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color("AccentColor"))
    }
}
