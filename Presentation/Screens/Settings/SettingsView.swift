// Presentation/Screens/Settings/SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.appTheme) private var theme
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled = false
    @AppStorage("colorScheme") private var colorScheme = "system"
    
    var body: some View {
        NavigationStack {
            List {
                // User Section
                userSection
                
                // Preferences Section
                preferencesSection
                
                // Data Section
                dataSection
                
                // About Section
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "settings.title"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Sections
    private var userSection: some View {
        Section {
            if let player = viewModel.player {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xxSmall) {
                        Text(player.username.isEmpty ? "Player" : player.username)
                            .font(theme.typography.headline)
                        
                        Text("Level \(player.level) • \(player.totalXP) XP")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(theme.colors.primary)
                }
                .padding(.vertical, theme.spacing.xSmall)
            }
        }
        .task {
            await viewModel.loadPlayer(appContainer: appContainer)
        }
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            // Sound Effects
            SettingRow(
                title: String(localized: "settings.sound_effects"),
                icon: "speaker.wave.2.fill",
                iconColor: .orange
            ) {
                Toggle("", isOn: $soundEffectsEnabled)
                    .labelsHidden()
            }
            
            // Haptic Feedback
            SettingRow(
                title: String(localized: "settings.haptic_feedback"),
                icon: "hand.tap.fill",
                iconColor: .purple
            ) {
                Toggle("", isOn: $hapticFeedbackEnabled)
                    .labelsHidden()
            }
            
            // Appearance
            SettingRow(
                title: "Appearance",
                icon: "moon.circle.fill",
                iconColor: .indigo
            ) {
                Picker("", selection: $colorScheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
        }
    }
    
    private var dataSection: some View {
        Section("Data & Storage") {
            // iCloud Sync
            SettingRow(
                title: String(localized: "settings.cloud_sync"),
                icon: "icloud.fill",
                iconColor: .blue
            ) {
                Toggle("", isOn: $cloudSyncEnabled)
                    .labelsHidden()
                    .onChange(of: cloudSyncEnabled) { _, newValue in
                        Task {
                            await viewModel.toggleCloudSync(
                                enabled: newValue,
                                appContainer: appContainer
                            )
                        }
                    }
            }
            
            // Clear Cache
            SettingRow(
                title: "Clear Cache",
                icon: "trash.fill",
                iconColor: .red,
                action: {
                    // Future implementation
                }
            )
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            // Version
            SettingRow(
                title: "Version",
                icon: "info.circle.fill",
                iconColor: .gray
            ) {
                Text("1.0.0")
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            // Privacy Policy
            SettingRow(
                title: "Privacy Policy",
                icon: "lock.fill",
                iconColor: .green,
                showDisclosure: true,
                action: {
                    // Open privacy policy
                }
            )
            
            // Terms of Service
            SettingRow(
                title: "Terms of Service",
                icon: "doc.text.fill",
                iconColor: .blue,
                showDisclosure: true,
                action: {
                    // Open terms
                }
            )
            
            // Rate App
            SettingRow(
                title: "Rate HolyTrivia",
                icon: "star.fill",
                iconColor: theme.colors.gold,
                showDisclosure: true,
                action: {
                    // Open App Store
                }
            )
        }
    }
}

// MARK: - Setting Row Component
struct SettingRow<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    var showDisclosure: Bool = false
    var action: (() -> Void)? = nil
    @ViewBuilder var accessory: () -> Content
    
    @Environment(\.appTheme) private var theme
    
    init(
        title: String,
        icon: String,
        iconColor: Color,
        showDisclosure: Bool = false,
        action: (() -> Void)? = nil
    ) where Content == EmptyView {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.showDisclosure = showDisclosure
        self.action = action
        self.accessory = { EmptyView() }
    }
    
    init(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder accessory: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.showDisclosure = false
        self.action = nil
        self.accessory = accessory
    }
    
    var body: some View {
        HStack(spacing: theme.spacing.small) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(6)
            
            Text(title)
                .font(theme.typography.body)
            
            Spacer()
            
            accessory()
            
            if showDisclosure {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}
