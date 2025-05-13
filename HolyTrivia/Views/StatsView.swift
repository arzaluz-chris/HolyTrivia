// StatsView.swift
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var statsViewModel: StatsViewModel
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Resumen general
                        VStack(spacing: 16) {
                            HStack {
                                Text("Summary")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PrimaryTextColor"))
                                
                                Spacer()
                                
                                Button(action: {
                                    statsViewModel.loadData()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(Color("PrimaryColor"))
                                }
                            }
                            
                            // Tarjetas de estadísticas
                            HStack(spacing: 12) {
                                StatCard(
                                    value: "\(statsViewModel.userStats.totalGames)",
                                    label: "Games",
                                    icon: "gamecontroller.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    value: "\(Int(statsViewModel.userStats.overallAccuracy * 100))%",
                                    label: "Accuracy",
                                    icon: "checkmark.seal.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    value: "\(statsViewModel.calculateMasteryLevel())",
                                    label: "Level",
                                    icon: "star.fill",
                                    color: .orange
                                )
                            }
                            
                            // Última vez jugado
                            if statsViewModel.userStats.totalGames > 0 {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color("SecondaryTextColor"))
                                    
                                    Text("Last played: \(statsViewModel.lastPlayedFormatted)")
                                        .font(.caption)
                                        .foregroundColor(Color("SecondaryTextColor"))
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        
                        // Progreso por categoría
                        if statsViewModel.userStats.categoryStats.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color("PrimaryColor").opacity(0.5))
                                
                                Text("No stats yet")
                                    .font(.headline)
                                    .foregroundColor(Color("PrimaryTextColor"))
                                
                                Text("Complete your first quiz to see your statistics!")
                                    .font(.subheadline)
                                    .foregroundColor(Color("SecondaryTextColor"))
                                    .multilineTextAlignment(.center)
                                
                                NavigationLink(destination: CategoriesView()) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("Start Playing")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("PrimaryColor"))
                                    )
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        } else {
                            // Categorías
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Category Progress")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                    
                                    Spacer()
                                }
                                
                                ForEach(statsViewModel.getCategoryStats(), id: \.category.id) { item in
                                    CategoryProgressView(
                                        category: item.category,
                                        stat: item.stat
                                    )
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            
                            // Historial reciente
                            if !statsViewModel.quizHistory.isEmpty {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Recent History")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("PrimaryTextColor"))
                                        
                                        Spacer()
                                    }
                                    
                                    ForEach(Array(statsViewModel.quizHistory.prefix(5))) { result in
                                        QuizHistoryItemView(
                                            result: result,
                                            categoryName: statsViewModel.getCategoryName(forId: result.categoryId)
                                        )
                                    }
                                    
                                    if statsViewModel.quizHistory.count > 5 {
                                        Text("+ \(statsViewModel.quizHistory.count - 5) more games")
                                            .font(.caption)
                                            .foregroundColor(Color("SecondaryTextColor"))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal)
                            }
                            
                            // Botón de reseteo
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Reset All Statistics")
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Statistics")
                .alert(isPresented: $showResetAlert) {
                    Alert(
                        title: Text("Reset Statistics"),
                        message: Text("This will delete all your quiz history and progress. This action cannot be undone."),
                        primaryButton: .destructive(Text("Reset")) {
                            statsViewModel.resetAllStats()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .onAppear {
            statsViewModel.loadData()
        }
    }
}

struct StatCard: View {
    var value: String
    var label: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            Text(label)
                .font(.caption)
                .foregroundColor(Color("SecondaryTextColor"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct CategoryProgressView: View {
    var category: Category
    var stat: CategoryStat
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: category.systemIconName)
                    .font(.headline)
                    .foregroundColor(category.color)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(category.color.opacity(0.2))
                    )
                
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Spacer()
                
                Text("\(Int(stat.accuracy * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(category.color)
            }
            
            HStack(spacing: 16) {
                // Barra de progreso
                ProgressView(value: stat.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: category.color))
                
                // Valor de progreso
                Text("\(stat.answeredQuestions)/\(stat.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .frame(width: 50)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct QuizHistoryItemView: View {
    var result: QuizResult
    var categoryName: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.headline)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Text(formattedDate(result.date))
                    .font(.caption)
                    .foregroundColor(Color("SecondaryTextColor"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(result.correctAnswers)/\(result.questionsCount)")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryColor"))
                
                Text("\(Int(result.accuracy * 100))%")
                    .font(.caption)
                    .foregroundColor(Color("SecondaryTextColor"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(StatsViewModel())
            .environmentObject(CategoriesViewModel())
    }
}
