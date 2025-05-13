// QuizViewModel.swift
import Foundation
import Combine

class QuizViewModel: ObservableObject {
    // Publicadas para actualizar la UI
    @Published var currentQuestion: Question?
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswerIndex: Int?
    @Published var isCorrectAnswer: Bool?
    @Published var isQuizCompleted: Bool = false
    @Published var score: Int = 0
    @Published var showFeedback: Bool = false
    @Published var quizResult: QuizResult?
    
    // Datos del quiz
    private var category: Category
    private var timerManager = TimerManager(timeInterval: 15)
    private var startTime: Date?
    private var questionsPerQuiz: Int
    
    // Para reproducir sonidos
    private let soundPlayer = SoundPlayer.shared
    
    // Inicialización con categoría seleccionada
    init(category: Category, questionsCount: Int = 10) {
        self.category = category
        self.questionsPerQuiz = questionsCount
        
        // Cargar preguntas de la categoría
        loadQuestions()
    }
    
    // Cargar preguntas de la categoría seleccionada
    private func loadQuestions() {
        // Obtener todas las preguntas
        let allQuestions = PersistenceManager.shared.loadQuestions()
        
        // Filtrar por categoría
        let categoryQuestions = allQuestions.filter { $0.category == category.id }
        
        // Tomar un número determinado de preguntas aleatorias
        questions = Array(categoryQuestions.shuffled().prefix(questionsPerQuiz))
        
        // Establecer la primera pregunta
        if !questions.isEmpty {
            currentQuestion = questions[0]
        }
    }
    
    // Iniciar el quiz
    func startQuiz() {
        currentQuestionIndex = 0
        score = 0
        isQuizCompleted = false
        selectedAnswerIndex = nil
        isCorrectAnswer = nil
        showFeedback = false
        
        if !questions.isEmpty {
            currentQuestion = questions[0]
        }
        
        startTime = Date()
        startTimer()
    }
    
    // Iniciar el temporizador para la pregunta actual
    func startTimer() {
        timerManager.reset()
        timerManager.start { [weak self] in
            self?.handleTimeUp()
        }
    }
    
    // Manejar cuando se acaba el tiempo
    private func handleTimeUp() {
        if selectedAnswerIndex == nil {
            // El usuario no respondió, marcar como incorrecto
            soundPlayer.play(.incorrect)
            selectedAnswerIndex = -1
            isCorrectAnswer = false
            showFeedback = true
            
            // Pasar a la siguiente pregunta después de un tiempo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.nextQuestion()
            }
        }
    }
    
    // Verificar respuesta
    func submitAnswer(_ index: Int) {
        guard let question = currentQuestion, selectedAnswerIndex == nil else { return }
        
        selectedAnswerIndex = index
        isCorrectAnswer = question.isCorrect(index)
        showFeedback = true
        
        if isCorrectAnswer ?? false {
            score += 1
            soundPlayer.play(.correct)
        } else {
            soundPlayer.play(.incorrect)
        }
        
        timerManager.stop()
        
        // Pasar a la siguiente pregunta después de un tiempo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.nextQuestion()
        }
    }
    
    // Pasar a la siguiente pregunta
    func nextQuestion() {
        // Ocultar feedback
        showFeedback = false
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            selectedAnswerIndex = nil
            isCorrectAnswer = nil
            startTimer()
        } else {
            // Quiz completado
            finishQuiz()
        }
    }
    
    // Finalizar el quiz
    func finishQuiz() {
        timerManager.stop()
        isQuizCompleted = true
        
        let endTime = Date()
        let timeSpent = endTime.timeIntervalSince(startTime ?? endTime)
        
        // Crear resultado del quiz
        quizResult = QuizResult(
            date: Date(),
            categoryId: category.id,
            questionsCount: questions.count,
            correctAnswers: score,
            timeSpent: timeSpent
        )
        
        // Guardar resultado
        if let result = quizResult {
            PersistenceManager.shared.addQuizResult(result)
        }
    }
    
    // Obtener puntuación como porcentaje
    var scorePercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(score) / Double(questions.count) * 100
    }
    
    // Verificar si el índice es la respuesta correcta
    func isCorrectOption(_ index: Int) -> Bool {
        guard let question = currentQuestion else { return false }
        return index == question.correctOption
    }
    
    // Obtener progreso actual
    var progressPercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    // Obtener objeto de timer para la vista
    var timer: TimerManager {
        return timerManager
    }
}
