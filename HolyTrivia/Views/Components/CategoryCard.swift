// CategoryCardView.swift
import SwiftUI

struct CategoryCardView: View {
    var category: Category
    var stats: CategoryStat?
    var hasQuestions: Bool
    
    init(category: Category, stats: CategoryStat?, hasQuestions: Bool = true) {
        self.category = category
        self.stats = stats
        self.hasQuestions = hasQuestions
    }
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            LinearGradient(
                gradient: Gradient(colors: [category.color, category.color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            .opacity(hasQuestions ? 1.0 : 0.5)
            
            HStack(spacing: 16) {
                // Ícono
                Image(systemName: category.systemIconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Título
                    HStack {
                        Text(category.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if !hasQuestions {
                            Text("(Sin preguntas)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                    }
                    
                    // Progreso
                    if let stats = stats {
                        ProgressView(value: stats.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(height: 8)
                        
                        HStack {
                            Text("\(stats.answeredQuestions) de \(stats.totalQuestions) preguntas")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text("\(Int(stats.accuracy * 100))% correcto")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    } else {
                        if hasQuestions {
                            Text("No jugado aún")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.vertical, 16)
                
                Spacer()
                
                // Flecha para indicar que es seleccionable
                Image(systemName: hasQuestions ? "chevron.right" : "lock.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 100)
    }
}
