// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @State private var soundEnabled = SoundPlayer.shared.isSoundOn()
    @State private var showAboutSheet = false
    @State private var selectedQuestionCount = 10
    @AppStorage("appColorTheme") private var colorTheme = "Default"
    
    let questionCountOptions = [5, 10, 15, 20]
    let colorThemeOptions = ["Default", "Ocean", "Nature", "Sunset"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Ajustes de juego
                        SettingsSectionView(title: "Game Settings") {
                            // Sonido
                            Toggle(isOn: $soundEnabled) {
                                SettingsRowView(
                                    icon: "speaker.wave.2.fill",
                                    title: "Sound Effects",
                                    color: .blue
                                )
                            }
                            .onChange(of: soundEnabled) { newValue in
                                SoundPlayer.shared.toggleSound()
                            }
                            
                            // Preguntas por defecto
                            SettingsRowView(
                                icon: "number.circle.fill",
                                title: "Default Questions",
                                color: .purple
                            ) {
                                Picker("", selection: $selectedQuestionCount) {
                                    ForEach(questionCountOptions, id: \.self) { count in
                                        Text("\(count)").tag(count)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            // Tema de color
                            SettingsRowView(
                                icon: "paintpalette.fill",
                                title: "Color Theme",
                                color: .green
                            ) {
                                Menu {
                                    ForEach(colorThemeOptions, id: \.self) { theme in
                                        Button(action: {
                                            colorTheme = theme
                                        }) {
                                            HStack {
                                                Text(theme)
                                                if theme == colorTheme {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(colorTheme)
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(Color("PrimaryColor"))
                                }
                            }
                        }
                        
                        // Acerca de
                        SettingsSectionView(title: "About") {
                            Button(action: {
                                showAboutSheet = true
                            }) {
                                SettingsRowView(
                                    icon: "info.circle.fill",
                                    title: "About HolyTrivia",
                                    color: .orange
                                ) {
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                        .foregroundColor(Color.gray)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Link(destination: URL(string: "https://example.com/privacy")!) {
                                SettingsRowView(
                                    icon: "hand.raised.fill",
                                    title: "Privacy Policy",
                                    color: .red
                                ) {
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(Color.gray)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Link(destination: URL(string: "https://example.com/feedback")!) {
                                SettingsRowView(
                                    icon: "envelope.fill",
                                    title: "Send Feedback",
                                    color: .blue
                                ) {
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(Color.gray)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Versión de la aplicación
                        HStack {
                            Spacer()
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Settings")
                .sheet(isPresented: $showAboutSheet) {
                    AboutView()
                }
            }
        }
    }
}

struct SettingsSectionView<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
}

struct SettingsRowView<Content: View>: View {
    var icon: String
    var title: String
    var color: Color
    @ViewBuilder var content: Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content = { EmptyView() }) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(Color("PrimaryTextColor"))
            
            Spacer()
            
            content
        }
        .padding()
        .background(Color.white)
        .overlay(
            Divider()
                .opacity(0.5)
            ,alignment: .bottom
        )
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        )
                        .padding(.top)
                    
                    Text("HolyTrivia")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryColor"))
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        AboutSectionText(title: "About the App") {
                            Text("HolyTrivia is an educational app designed to help users learn and test their knowledge of the Bible through engaging quizzes and challenges.")
                        }
                        
                        AboutSectionText(title: "How to Play") {
                            Text("1. Select a category of Bible questions\n2. Choose how many questions you want to answer\n3. Answer the questions before the timer runs out\n4. See your results and track your progress")
                        }
                        
                        AboutSectionText(title: "Credits") {
                            Text("App developed by [Your Name]\nBible questions sourced from verified theological resources\nIcons by SF Symbols")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle("About", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color("BackgroundColor").ignoresSafeArea())
        }
    }
}

struct AboutSectionText<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("PrimaryColor"))
            
            content
                .font(.body)
                .foregroundColor(Color("PrimaryTextColor"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
