//
//  DirectQuizView.swift
//  HolyTrivia
//
//  Created by Christian Arzaluz on 13/05/25.
//


// DirectQuizView.swift
import SwiftUI

struct DirectQuizView: View {
    let category: Category
    let questionsCount: Int
    let onDismiss: () -> Void
    
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var quizCompleted = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if questions.isEmpty {
                    errorView(message: "No hay preguntas disponibles para esta categoría")
                } else if quizCompleted {
                    resultView
                } else {
                    questionView
                }
            }
            .navigationBarTitle(category.name, displayMode: .inline)
            .navigationBarItems(leading: Button("Salir") {
                onDismiss()
            })
        }
        .onAppear {
            // Cargar preguntas inmediatamente
            loadQuestions()
        }
    }
    
    // MARK: - Subviews
    
    var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando preguntas...")
                .padding()
        }
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Volver a Categorías") {
                onDismiss()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color("PrimaryColor"))
            .cornerRadius(10)
        }
        .padding()
    }
    
    var questionView: some View {
        VStack {
            // Progress indicator
            ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count - 1))
                .padding()
            
            HStack {
                Text("Pregunta \(currentQuestionIndex + 1) de \(questions.count)")
                    .font(.subheadline)
                
                Spacer()
                
                Text("Puntuación: \(score)")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color("PrimaryColor").opacity(0.1))
                    )
            }
            .padding(.horizontal)
            
            // Question
            ScrollView {
                VStack(spacing: 20) {
                    Text(questions[currentQuestionIndex].text)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Options
                    ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                        Button(action: {
                            if selectedAnswer == nil {
                                selectedAnswer = index
                                processAnswer()
                            }
                        }) {
                            HStack {
                                Text("\(["A", "B", "C", "D"][index])")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(optionColor(for: index))
                                    )
                                
                                Text(questions[currentQuestionIndex].options[index])
                                    .font(.body)
                                    .foregroundColor(Color("PrimaryTextColor"))
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if let selected = selectedAnswer {
                                    if selected == index {
                                        Image(systemName: isCorrectAnswer(index) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(isCorrectAnswer(index) ? .green : .red)
                                    } else if isCorrectAnswer(index) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                        }
                        .disabled(selectedAnswer != nil)
                        .padding(.horizontal)
                    }
                    
                    if selectedAnswer != nil {
                        Button(currentQuestionIndex < questions.count - 1 ? "Siguiente Pregunta" : "Ver Resultados") {
                            goToNextQuestion()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(10)
                        .padding(.top, 20)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: score > questions.count / 2 ? "star.circle.fill" : "book.circle")
                .font(.system(size: 80))
                .foregroundColor(Color("PrimaryColor"))
            
            Text(score > questions.count / 2 ? "¡Buen trabajo!" : "Sigue aprendiendo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(score) de \(questions.count) respuestas correctas")
                .font(.title2)
            
            Text("\(Int(Double(score) / Double(questions.count) * 100))%")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(scoreColor)
            
            Button("Volver a Categorías") {
                onDismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color("PrimaryColor"))
            .cornerRadius(10)
            .padding(.top, 20)
        }
        .padding()
    }
    
    // MARK: - Helper methods
    
    func loadQuestions() {
        isLoading = true
        errorMessage = nil
        
        print("DirectQuizView: Cargando preguntas para \(category.name)")
        
        // Cargar preguntas inmediatamente desde PersistenceManager
        let categoryQuestions = PersistenceManager.shared.loadQuestionsFor(categoryId: category.id)
        
        if categoryQuestions.isEmpty {
            errorMessage = "No hay preguntas disponibles para esta categoría"
            isLoading = false
            return
        }
        
        // Aleatorizar y tomar el número solicitado
        let shuffled = categoryQuestions.shuffled()
        let selected = Array(shuffled.prefix(min(questionsCount, categoryQuestions.count)))
        
        questions = selected
        print("DirectQuizView: Cargadas \(questions.count) preguntas")
        isLoading = false
    }
    
    func processAnswer() {
        if let selected = selectedAnswer {
            if isCorrectAnswer(selected) {
                score += 1
            }
        }
    }
    
    func goToNextQuestion() {
        selectedAnswer = nil
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            quizCompleted = true
            saveResults()
        }
    }
    
    func saveResults() {
        // Crear y guardar resultados
        let result = QuizResult(
            date: Date(),
            categoryId: category.id,
            questionsCount: questions.count,
            correctAnswers: score,
            timeSpent: 0 // No estamos midiendo tiempo en esta versión simplificada
        )
        
        PersistenceManager.shared.addQuizResult(result)
    }
    
    func isCorrectAnswer(_ index: Int) -> Bool {
        return index == questions[currentQuestionIndex].correctOption
    }
    
    func optionColor(for index: Int) -> Color {
        if let selected = selectedAnswer {
            if selected == index {
                return isCorrectAnswer(index) ? .green : .red
            } else if isCorrectAnswer(index) {
                return .green
            }
        }
        
        return Color("PrimaryColor")
    }
    
    var scoreColor: Color {
        let percentage = Double(score) / Double(questions.count)
        
        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.6 {
            return .blue
        } else if percentage >= 0.4 {
            return .orange
        } else {
            return .red
        }
    }
}