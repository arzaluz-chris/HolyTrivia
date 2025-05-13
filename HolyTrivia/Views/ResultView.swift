// ResultView.swift
import SwiftUI

struct ResultView: View {
    var quizResult: QuizResult
    var score: Int
    var totalQuestions: Int
    var onBackToCategories: () -> Void
    
    @State private var animateScore = false
    @State private var showMessage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Imagen de resultado
                getResultImage()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .scaleEffect(animateScore ? 1.0 : 0.5)
                    .opacity(animateScore ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5), value: animateScore)
                
                // Puntuación
                VStack(spacing: 10) {
                    Text(resultTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .multilineTextAlignment(.center)
                        .opacity(showMessage ? 1 : 0)
                        .animation(.easeIn.delay(0.3), value: showMessage)
                    
                    Text("\(score) of \(totalQuestions) correct")
                        .font(.title)
                        .foregroundColor(Color("PrimaryColor"))
                        .fontWeight(.bold)
                        .opacity(showMessage ? 1 : 0)
                        .animation(.easeIn.delay(0.5), value: showMessage)
                    
                    // Porcentaje
                    Text("\(Int(Double(score) / Double(totalQuestions) * 100))%")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(resultTextColor)
                        .padding(.vertical, 10)
                        .scaleEffect(animateScore ? 1.0 : 0.8)
                        .opacity(animateScore ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5).delay(0.2), value: animateScore)
                }
                
                // Detalles del resultado
                VStack(spacing: 15) {
                    resultDetailView(
                        icon: "clock.fill",
                        title: "Time Spent",
                        value: formatTimeInterval(quizResult.timeSpent),
                        color: .blue
                    )
                    
                    resultDetailView(
                        icon: "checkmark.circle.fill",
                        title: "Accuracy",
                        value: "\(Int(quizResult.accuracy * 100))%",
                        color: .green
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                )
                .padding(.horizontal)
                .offset(y: showMessage ? 0 : 50)
                .opacity(showMessage ? 1 : 0)
                .animation(.easeOut.delay(0.7), value: showMessage)
                
                // Mensaje motivador
                Text(motivationalMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("SecondaryTextColor"))
                    .padding()
                    .offset(y: showMessage ? 0 : 30)
                    .opacity(showMessage ? 1 : 0)
                    .animation(.easeOut.delay(0.9), value: showMessage)
                
                // Botones
                VStack(spacing: 16) {
                    Button(action: onBackToCategories) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Back to Categories")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("PrimaryColor"))
                        )
                    }
                    
                    Button(action: {
                        // Acción para compartir resultado
                        let message = "I scored \(score)/\(totalQuestions) (\(Int(Double(score) / Double(totalQuestions) * 100))%) in HolyTrivia Bible Quiz!"
                        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Result")
                        }
                        .font(.headline)
                        .foregroundColor(Color("PrimaryColor"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("PrimaryColor"), lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .offset(y: showMessage ? 0 : 60)
                .opacity(showMessage ? 1 : 0)
                .animation(.easeOut.delay(1.1), value: showMessage)
            }
            .padding(.vertical, 30)
        }
        .onAppear {
            // Animación secuencial al aparecer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateScore = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showMessage = true
            }
        }
        .background(Color("BackgroundColor"))
    }
    
    // Formato de tiempo
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds) seconds"
        }
    }
    
    // Imagen basada en el resultado
    func getResultImage() -> Image {
        let percentage = Double(score) / Double(totalQuestions)
        
        if percentage >= 0.8 {
            return Image(systemName: "star.circle.fill")
        } else if percentage >= 0.6 {
            return Image(systemName: "hand.thumbsup.circle.fill")
        } else if percentage >= 0.4 {
            return Image(systemName: "face.smiling")
        } else {
            return Image(systemName: "book.circle")
        }
    }
    
    // Título basado en el rendimiento
    var resultTitle: String {
        let percentage = Double(score) / Double(totalQuestions)
        
        if percentage >= 0.9 {
            return "Excellent! 🎉"
        } else if percentage >= 0.7 {
            return "Great job! 👏"
        } else if percentage >= 0.5 {
            return "Good work! 👍"
        } else if percentage >= 0.3 {
            return "Nice try! 💪"
        } else {
            return "Keep learning! 📚"
        }
    }
    
    // Color basado en el rendimiento
    var resultTextColor: Color {
        let percentage = Double(score) / Double(totalQuestions)
        
        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.6 {
            return .blue
        } else if percentage >= 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Mensaje motivacional basado en el rendimiento
    var motivationalMessage: String {
        let percentage = Double(score) / Double(totalQuestions)
        
        if percentage >= 0.9 {
            return "Amazing! Your Bible knowledge is impressive. Keep studying God's word!"
        } else if percentage >= 0.7 {
            return "Well done! You have a solid understanding of the scriptures. Continue to grow in knowledge!"
        } else if percentage >= 0.5 {
            return "Good effort! Daily reading will help you improve your understanding of the Bible."
        } else if percentage >= 0.3 {
            return "You're on the right path! Keep exploring the scriptures to deepen your knowledge."
        } else {
            return "The journey of learning has just begun! The more you study, the more you'll discover."
        }
    }
    
    // Vista de detalle de resultado
    func resultDetailView(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("SecondaryTextColor"))
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
                    let result = QuizResult(
                        date: Date(),
                        categoryId: "old_testament",
                        questionsCount: 10,
                        correctAnswers: 8,
                        timeSpent: 120
                    )
                    
                    ResultView(
                        quizResult: result,
                        score: 8,
                        totalQuestions: 10,
                        onBackToCategories: {}
                    )
                }
            }
