// HomeView.swift (fixed)
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var statsViewModel: StatsViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainMenuView(onPlayTapped: {
                selectedTab = 1
            })
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            CategoriesView()
            .tabItem {
                Label("Play", systemImage: "play.fill")
            }
            .tag(1)
            
            StatsView()
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(2)
            
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .accentColor(Color("AccentColor"))
        .onAppear {
            // Cargar datos cuando la app aparece
            categoriesViewModel.loadCategories()
            statsViewModel.loadData()
        }
    }
}

struct MainMenuView: View {
    var onPlayTapped: () -> Void
    @EnvironmentObject var statsViewModel: StatsViewModel
    @State private var showAnimation = false
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient(
                gradient: Gradient(colors: [Color("PrimaryColor"), Color("SecondaryColor")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Contenido principal
            VStack(spacing: 30) {
                // Logo y título
                VStack(spacing: 10) {
                    Image("AppLogo") // Asegúrate de tener esta imagen en Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .scaleEffect(showAnimation ? 1.0 : 0.8)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5), value: showAnimation)
                    
                    Text("HolyTrivia")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                        .padding(.top, 5)
                        .offset(y: showAnimation ? 0 : 20)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.7).delay(0.3), value: showAnimation)
                    
                    Text("Test your Bible knowledge")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom)
                        .offset(y: showAnimation ? 0 : 20)
                        .opacity(showAnimation ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.7).delay(0.4), value: showAnimation)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Información de estadísticas
                VStack(spacing: 15) {
                    if statsViewModel.userStats.totalGames > 0 {
                        StatInfoView(
                            icon: "star.fill",
                            value: "\(statsViewModel.calculateMasteryLevel())/5",
                            label: "Mastery Level",
                            color: .yellow
                        )
                        
                        StatInfoView(
                            icon: "checkmark.circle.fill",
                            value: "\(Int(statsViewModel.userStats.overallAccuracy * 100))%",
                            label: "Accuracy",
                            color: .green
                        )
                        
                        StatInfoView(
                            icon: "number.circle.fill",
                            value: "\(statsViewModel.userStats.totalGames)",
                            label: "Games Played",
                            color: .blue
                        )
                    } else {
                        Text("Complete your first quiz to see your stats!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }
                .offset(y: showAnimation ? 0 : 40)
                .opacity(showAnimation ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.7).delay(0.6), value: showAnimation)
                
                Spacer()
                
                // Botón de jugar
                Button(action: onPlayTapped) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.title2)
                        Text("Start Playing")
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 50)
                    .background(
                        Capsule()
                            .fill(Color("AccentColor"))
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                    )
                }
                .offset(y: showAnimation ? 0 : 60)
                .opacity(showAnimation ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.7).delay(0.8), value: showAnimation)
                .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showAnimation = true
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CategoriesViewModel())
            .environmentObject(StatsViewModel())
    }
}
