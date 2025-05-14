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
    @Published var isLoading: Bool = true
    @Published var errorLoading: Bool = false
    @Published var noCategoryQuestions: Bool = false
    @Published var isQuizStarted: Bool = false
    
    // Datos del quiz
    private var category: Category
    private var timerManager = TimerManager(timeInterval: 15)
    private var startTime: Date?
    private var questionsPerQuiz: Int
    
    // Para reproducir sonidos
    private let soundPlayer = SoundPlayer.shared
    
    // Inicialización con categoría seleccionada
    init(category: Category, questionsCount: Int = 10) {
        print("Inicializando QuizViewModel con categoría: \(category.name), preguntas: \(questionsCount)")
        self.category = category
        self.questionsPerQuiz = questionsCount
        self.isLoading = true
        
        // Cargar preguntas de la categoría inmediatamente
        loadQuestions()
    }
    
    // Cargar preguntas de la categoría seleccionada
    private func loadQuestions() {
        isLoading = true
        errorLoading = false
        noCategoryQuestions = false
        
        print("Iniciando carga de preguntas para categoría: \(category.id)")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                print("ERROR: Self fue liberado durante carga de preguntas")
                return
            }
            
            // Obtener todas las preguntas
            let allQuestions = PersistenceManager.shared.loadQuestions()
            print("Total de preguntas cargadas: \(allQuestions.count)")
            
            if allQuestions.isEmpty {
                print("ERROR: No se pudieron cargar preguntas del JSON")
                DispatchQueue.main.async {
                    self.errorLoading = true
                    self.isLoading = false
                }
                return
            }
            
            // Filtrar por categoría
            let categoryQuestions = allQuestions.filter { $0.category == self.category.id }
            print("Preguntas de la categoría \(self.category.id): \(categoryQuestions.count)")
            
            // Si no hay preguntas para esta categoría
            if categoryQuestions.isEmpty {
                print("No se encontraron preguntas para la categoría: \(self.category.id)")
                DispatchQueue.main.async {
                    self.noCategoryQuestions = true
                    self.isLoading = false
                }
                return
            }
            
            // Tomar un número determinado de preguntas aleatorias
            let shuffledQuestions = categoryQuestions.shuffled()
            let count = min(self.questionsPerQuiz, shuffledQuestions.count)
            let selectedQuestions = Array(shuffledQuestions.prefix(count))
            
            print("Preguntas seleccionadas aleatoriamente: \(selectedQuestions.count)")
            print("Primera pregunta: \(selectedQuestions.first?.text ?? "Ninguna")")
            
            DispatchQueue.main.async {
                self.questions = selectedQuestions
                
                // Establecer la primera pregunta explícitamente
                if !self.questions.isEmpty {
                    self.currentQuestion = self.questions[0]
                    print("Primera pregunta establecida: \(self.currentQuestion?.text ?? "Ninguna")")
                    
                    // Inicializar el estado del quiz ahora que tenemos preguntas
                    self.initializeQuizState()
                } else {
                    print("ERROR: No se pudieron seleccionar preguntas")
                    self.errorLoading = true
                }
                
                self.isLoading = false
            }
        }
    }
    
    // Inicializar estado del quiz
    private func initializeQuizState() {
        print("Inicializando estado del quiz")
        
        currentQuestionIndex = 0
        score = 0
        isQuizCompleted = false
        selectedAnswerIndex = nil
        isCorrectAnswer = nil
        showFeedback = false
        
        startTime = Date()
        isQuizStarted = true
        
        // Iniciar temporizador después de todo lo demás
        startTimer()
        
        print("Estado del quiz inicializado - Primera pregunta: \(currentQuestion?.text ?? "Ninguna")")
    }
    
    // Iniciar manualmente el quiz
    func startQuiz() {
        print("Iniciando quiz manualmente - Preguntas: \(questions.count)")
        
        if isLoading {
            print("Quiz no iniciado - todavía cargando preguntas")
            return
        }
        
        if questions.isEmpty {
            print("No hay preguntas disponibles para iniciar quiz")
            return
        }
        
        // Solo reinicializar todo si no se ha hecho ya
        if !isQuizStarted {
            initializeQuizState()
        } else {
            print("El quiz ya está iniciado")
        }
    }
    
    // Iniciar el temporizador para la pregunta actual
    func startTimer() {
        print("Iniciando temporizador para pregunta actual")
        timerManager.reset()
        timerManager.start { [weak self] in
            self?.handleTimeUp()
        }
    }
    
    // Manejar cuando se acaba el tiempo
    private func handleTimeUp() {
        print("Tiempo agotado para la pregunta actual")
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
        
        print("Respuesta seleccionada: \(index) para pregunta: \(question.text)")
        
        selectedAnswerIndex = index
        isCorrectAnswer = question.isCorrect(index)
        showFeedback = true
        
        if isCorrectAnswer ?? false {
            score += 1
            soundPlayer.play(.correct)
            print("¡Respuesta correcta! Puntuación actual: \(score)")
        } else {
            soundPlayer.play(.incorrect)
            print("Respuesta incorrecta. Respuesta correcta era: \(question.correctOption)")
        }
        
        timerManager.stop()
        
        // Pasar a la siguiente pregunta después de un tiempo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.nextQuestion()
        }
    }
    
    // Pasar a la siguiente pregunta
    func nextQuestion() {
        print("Avanzando a la siguiente pregunta")
        
        // Ocultar feedback
        showFeedback = false
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            selectedAnswerIndex = nil
            isCorrectAnswer = nil
            startTimer()
            
            print("Nueva pregunta: \(currentQuestion?.text ?? "Ninguna")")
        } else {
            print("No hay más preguntas, finalizando quiz")
            // Quiz completado
            finishQuiz()
        }
    }
    
    // Finalizar el quiz
    func finishQuiz() {
        print("Finalizando quiz - Puntuación final: \(score)")
        
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
            print("Resultado guardado - Categoría: \(category.id), Puntuación: \(score)")
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
