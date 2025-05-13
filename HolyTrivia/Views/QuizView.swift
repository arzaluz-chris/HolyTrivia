// QuizView.swift
import SwiftUI

struct QuizView: View {
    @ObservedObject var quizViewModel: QuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitAlert = false
    @State private var animateCorrectAnswer = false
    @State private var progressBarValue = 0.0
    
    var body: some View {
        ZStack {
            // Fondo
            Color("BackgroundColor").ignoresSafeArea()
            
            if quizViewModel.isQuizCompleted {
                // Pantalla de resultado
                ResultView(
                    quizResult: quizViewModel.quizResult!,
                    score: quizViewModel.score,
                    totalQuestions: quizViewModel.questions.count,
                    onBackToCategories: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            } else {
                // Pantalla de preguntas
                VStack(spacing: 0) {
                    // Cabecera con progreso
                    VStack(spacing: 8) {
                        HStack {
                            Button(action: {
                                showExitAlert = true
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundColor(Color("PrimaryTextColor"))
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Puntuación
                            Text("Score: \(quizViewModel.score)")
                                .font(.headline)
                                .foregroundColor(Color("PrimaryColor"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color("PrimaryColor").opacity(0.1))
                                )
                        }
                        .padding(.horizontal)
                        
                        // Barra de progreso
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Fondo de barra
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                
                                // Barra de progreso
                                Rectangle()
                                    .fill(Color("PrimaryColor"))
                                    .cornerRadius(10)
                                    .frame(width: geometry.size.width * CGFloat(progressBarValue))
                                    .animation(.spring(), value: progressBarValue)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    if let currentQuestion = quizViewModel.currentQuestion {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Imagen de la pregunta
                                if let imageRef = currentQuestion.imageRef {
                                    Image(imageRef)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(16)
                                        .padding(.horizontal)
                                        .padding(.top)
                                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                                } else {
                                    // Imagen placeholder
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(Color("PrimaryColor").opacity(0.7))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color("PrimaryColor").opacity(0.1))
                                        )
                                        .padding(.top)
                                }
                                
                                // Indicador de número de pregunta y temporizador
                                HStack {
                                    Text("Question \(quizViewModel.currentQuestionIndex + 1) of \(quizViewModel.questions.count)")
                                        .font(.subheadline)
                                        .foregroundColor(Color("SecondaryTextColor"))
                                    
                                    Spacer()
                                    
                                    TimerView(timerManager: quizViewModel.timer)
                                }
                                .padding(.horizontal)
                                
                                // Texto de la pregunta
                                Text(currentQuestion.text)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("PrimaryTextColor"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                // Opciones de respuesta
                                VStack(spacing: 12) {
                                    ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                                        OptionButtonView(
                                            text: currentQuestion.options[index],
                                            index: index,
                                            selectedIndex: quizViewModel.selectedAnswerIndex,
                                            correctIndex: quizViewModel.showFeedback ? currentQuestion.correctOption : nil,
                                            onTap: {
                                                quizViewModel.submitAnswer(index)
                                                
                                                if quizViewModel.isCorrectAnswer == true {
                                                    animateCorrectAnswer = true
                                                    
                                                    // Reset animation after 1 second
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        animateCorrectAnswer = false
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                    } else {
                        Spacer()
                        Text("Loading question...")
                            .font(.headline)
                            .foregroundColor(Color("SecondaryTextColor"))
                        Spacer()
                    }
                }
                .onAppear {
                    quizViewModel.startQuiz()
                }
                .onChange(of: quizViewModel.currentQuestionIndex) { _ in
                    // Actualizar barra de progreso
                    progressBarValue = Double(quizViewModel.currentQuestionIndex) / Double(max(1, quizViewModel.questions.count - 1))
                }
                .alert(isPresented: $showExitAlert) {
                    Alert(
                        title: Text("Exit Quiz?"),
                        message: Text("Your progress will be lost. Are you sure you want to exit?"),
                        primaryButton: .destructive(Text("Exit")) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                // Efecto de confeti cuando la respuesta es correcta
                if animateCorrectAnswer {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundColor(timerManager.progress < 0.3 ? .red : Color("SecondaryTextColor"))
            
            Text(String(format: "%.0f", timerManager.timeRemaining))
                .font(.subheadline)
                .foregroundColor(timerManager.progress < 0.3 ? .red : Color("SecondaryTextColor"))
                .fontWeight(timerManager.progress < 0.3 ? .bold : .regular)
                .frame(width: 25, alignment: .leading)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(timerManager.progress < 0.3 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

struct ConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: CGFloat.random(in: 5...12))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: isAnimating ? UIScreen.main.bounds.height + 100 : -100
                    )
                    .animation(
                        Animation.linear(duration: CGFloat.random(in: 1...3))
                            .delay(CGFloat.random(in: 0...0.5))
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let category = Category(id: "old_testament", name: "Antiguo Testamento", icon: "old_testament_icon")
        QuizView(quizViewModel: QuizViewModel(category: category))
    }
}
