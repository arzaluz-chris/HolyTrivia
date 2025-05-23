// QuizView.swift
import SwiftUI

struct QuizView: View {
    @StateObject private var quizViewModel: QuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitAlert = false
    @State private var animateCorrectAnswer = false
    @State private var progressBarValue = 0.0
    
    init(category: Category, questionsCount: Int) {
        print("Inicializando QuizView para categoría: \(category.name)")
        _quizViewModel = StateObject(wrappedValue: QuizViewModel(category: category, questionsCount: questionsCount))
    }
    
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
            } else if quizViewModel.isLoading {
                // Estado de carga
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Cargando preguntas...")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryTextColor"))
                }
            } else if quizViewModel.noCategoryQuestions {
                // Estado cuando la categoría no tiene preguntas
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(Color("PrimaryColor"))
                    
                    Text("Esta categoría aún no tiene preguntas disponibles")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Por favor, selecciona otra categoría para jugar")
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Volver a Categorías")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("PrimaryColor"))
                            )
                    }
                    .padding(.top)
                }
                .padding()
            } else if quizViewModel.errorLoading {
                // Estado de error
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Hubo un problema cargando las preguntas")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Volver a Categorías")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("PrimaryColor"))
                            )
                    }
                }
                .padding()
            } else if let currentQuestion = quizViewModel.currentQuestion {
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
                            Text("Puntuación: \(quizViewModel.score)")
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
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Imagen de la pregunta (placeholder por ahora)
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
                            
                            // Indicador de número de pregunta y temporizador
                            HStack {
                                Text("Pregunta \(quizViewModel.currentQuestionIndex + 1) de \(quizViewModel.questions.count)")
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
                                    Button(action: {
                                        if quizViewModel.selectedAnswerIndex == nil {
                                            quizViewModel.submitAnswer(index)
                                            
                                            if quizViewModel.isCorrectAnswer == true {
                                                animateCorrectAnswer = true
                                                
                                                // Reset animation after 1 second
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    animateCorrectAnswer = false
                                                }
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text("\(["A", "B", "C", "D"][index])")
                                                .font(.headline)
                                                .foregroundColor(optionForegroundColor(for: index))
                                                .frame(width: 30, height: 30)
                                                .background(
                                                    Circle()
                                                        .fill(optionBackgroundColor(for: index))
                                                )
                                            
                                            Text(currentQuestion.options[index])
                                                .font(.body)
                                                .foregroundColor(optionTextColor(for: index))
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if let selected = quizViewModel.selectedAnswerIndex, quizViewModel.showFeedback {
                                                if selected == index {
                                                    Image(systemName: selected == currentQuestion.correctOption ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .foregroundColor(selected == currentQuestion.correctOption ? .green : .red)
                                                } else if index == currentQuestion.correctOption {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(optionBackgroundColor(for: index))
                                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                        )
                                    }
                                    .disabled(quizViewModel.selectedAnswerIndex != nil)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Explicación (mostrada cuando se revela la respuesta correcta)
                            if quizViewModel.showFeedback {
                                Text(currentQuestion.explanation)
                                    .font(.subheadline)
                                    .foregroundColor(Color("SecondaryTextColor"))
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                    .padding(.horizontal)
                                    .transition(.opacity)
                                    .animation(.easeIn, value: quizViewModel.showFeedback)
                            }
                            
                            Spacer().frame(height: 40)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .alert(isPresented: $showExitAlert) {
                    Alert(
                        title: Text("¿Salir del Quiz?"),
                        message: Text("Tu progreso se perderá. ¿Estás seguro de que quieres salir?"),
                        primaryButton: .destructive(Text("Salir")) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }
                
                // Confetti effect when answer is correct
                if animateCorrectAnswer {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            } else {
                // Estado en el que no hay una pregunta actual, pero tampoco está cargando
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Error inesperado: no se pudo cargar la pregunta")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Volver a Categorías")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("PrimaryColor"))
                            )
                    }
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            print("QuizView onAppear - Estado actual: loading=\(quizViewModel.isLoading), preguntas=\(quizViewModel.questions.count)")
        }
        .onChange(of: quizViewModel.isLoading) { loading in
            print("Estado isLoading cambió a: \(loading)")
            if !loading {
                print("Carga completada: preguntas=\(quizViewModel.questions.count), currentQuestion=\(quizViewModel.currentQuestion?.text ?? "nil")")
                
                // Esta verificación es crítica y asegura que si tenemos preguntas pero no hay quiz iniciado, se inicie el quiz
                if !quizViewModel.questions.isEmpty && !quizViewModel.isQuizStarted {
                    print("Iniciando quiz después de carga...")
                    quizViewModel.startQuiz()
                    
                    // Asegurar que la barra de progreso se actualiza
                    progressBarValue = Double(quizViewModel.currentQuestionIndex) / Double(max(1, quizViewModel.questions.count - 1))
                }
            }
        }
        .onChange(of: quizViewModel.currentQuestionIndex) { newIndex in
            print("Índice de pregunta cambió a: \(newIndex)")
            // Update progress bar
            progressBarValue = Double(newIndex) / Double(max(1, quizViewModel.questions.count - 1))
        }
    }
    
    // Helper functions for option styling based on state
    private func optionBackgroundColor(for index: Int) -> Color {
        guard let selectedIndex = quizViewModel.selectedAnswerIndex, quizViewModel.showFeedback else {
            return Color.white
        }
        
        if selectedIndex == index {
            return selectedIndex == quizViewModel.currentQuestion?.correctOption ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        } else if index == quizViewModel.currentQuestion?.correctOption {
            return Color.green.opacity(0.2)
        }
        
        return Color.white
    }
    
    private func optionForegroundColor(for index: Int) -> Color {
        return optionTextColor(for: index)
    }
    
    private func optionTextColor(for index: Int) -> Color {
        guard let selectedIndex = quizViewModel.selectedAnswerIndex, quizViewModel.showFeedback else {
            return Color("PrimaryTextColor")
        }
        
        if selectedIndex == index {
            return selectedIndex == quizViewModel.currentQuestion?.correctOption ? .green : .red
        } else if index == quizViewModel.currentQuestion?.correctOption {
            return .green
        }
        
        return Color("PrimaryTextColor")
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
