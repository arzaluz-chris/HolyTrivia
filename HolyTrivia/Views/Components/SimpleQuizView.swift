//
//  SimpleQuizView.swift
//  HolyTrivia
//
//  Created by Christian Arzaluz on 13/05/25.
//


// SimpleQuizView.swift
import SwiftUI

struct SimpleQuizView: View {
    let category: Category
    let questionsCount: Int
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var quizCompleted = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
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
        .onAppear(perform: loadQuestions)
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
                presentationMode.wrappedValue.dismiss()
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
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Puntuación: \(score)")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color("PrimaryColor").opacity(0.1))
                    )
            }
            .padding(.horizontal)
            
            // Progress indicator
            ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                .padding()
            
            Text("Pregunta \(currentQuestionIndex + 1) de \(questions.count)")
                .font(.subheadline)
                .padding(.bottom)
            
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
                        Button("Siguiente Pregunta") {
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
        .padding(.vertical)
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
                presentationMode.wrappedValue.dismiss()
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
        
        print("SimpleQuizView: Cargando preguntas para \(category.name)")
        
        // Ejecutar en un hilo en segundo plano
        DispatchQueue.global(qos: .userInitiated).async {
            // Cargar todas las preguntas
            let allQuestions = PersistenceManager.shared.loadQuestions()
            
            // Filtrar por categoría
            let categoryQuestions = allQuestions.filter { $0.category == category.id }
            
            // Aleatorizar y tomar el número solicitado
            let shuffled = categoryQuestions.shuffled()
            let selected = Array(shuffled.prefix(questionsCount))
            
            // Volver al hilo principal
            DispatchQueue.main.async {
                if selected.isEmpty {
                    errorMessage = "No hay preguntas disponibles para esta categoría"
                } else {
                    questions = selected
                    print("SimpleQuizView: Cargadas \(questions.count) preguntas")
                }
                isLoading = false
            }
        }
    }
    
    func processAnswer() {
        if let selected = selectedAnswer {
            if isCorrectAnswer(selected) {
                score += 1
            }
            
            // Esperar un momento y luego avanzar
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // No avanzar automáticamente - el usuario pulsará un botón
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

struct SimpleQuizView_Previews: PreviewProvider {
    static var previews: some View {
        let category = Category(id: "test", name: "Test Category", icon: "star")
        SimpleQuizView(category: category, questionsCount: 5)
    }
}