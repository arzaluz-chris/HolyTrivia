// HolyTriviaApp.swift
import SwiftUI

@main
struct HolyTriviaApp: App {
    // Initialize the AppDelegate for system services
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Create ViewModel instances once and pass them to the views
    @StateObject private var categoriesViewModel = CategoriesViewModel()
    @StateObject private var statsViewModel = StatsViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(categoriesViewModel)
                .environmentObject(statsViewModel)
        }
    }
}
