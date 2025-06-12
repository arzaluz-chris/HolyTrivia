// Domain/UseCases/QuizEngine.swift

import Foundation
import Combine

final class QuizEngine: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var currentQuestionIndex: Int = 0
    @Published private(set) var sessionQuestions: [Question] = []
    @Published private(set) var answers: [AnswerRecord] = []
    @Published private(set) var timeRemaining: TimeInterval = 30
    @Published private(set) var isSessionActive: Bool = false
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var sessionResult: SessionResult?
    @Published private(set) var currentStreak: Int = 0
    
    // MARK: - Private Properties
    private let questionRepository: QuestionRepositoryProtocol
    private let xpCalculator: XPCalculator
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var questionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private let questionsPerSession = 10
    private let secondsPerQuestion: TimeInterval = 30
    
    // MARK: - Initialization
    init(
        questionRepository: QuestionRepositoryProtocol,
        xpCalculator: XPCalculator = XPCalculator()
    ) {
        self.questionRepository = questionRepository
        self.xpCalculator = xpCalculator
    }
    
    // MARK: - Public Methods
    func startSession(category: Category) async throws {
        // Reset state
        resetSession()
        
        // Load questions
        let allQuestions = try await questionRepository.loadQuestions(for: category)
        guard allQuestions.count >= questionsPerSession else {
            throw QuizError.insufficientQuestions
        }
        
        // Shuffle and select questions
        sessionQuestions = Array(allQuestions.shuffled().prefix(questionsPerSession))
        
        // Start session
        isSessionActive = true
        sessionStartTime = Date()
        
        // Load first question
        loadNextQuestion()
    }
    
    func submitAnswer(selectedIndex: Int) {
        guard let question = currentQuestion,
              let startTime = questionStartTime,
              isSessionActive && !isPaused else { return }
        
        // Stop timer
        stopTimer()
        
        // Calculate time spent
        let timeSpent = Date().timeIntervalSince(startTime)
        
        // Check if correct
        let isCorrect = selectedIndex == question.correctIndex
        
        // Update streak
        if isCorrect {
            currentStreak += 1
        } else {
            currentStreak = 0
        }
        
        // Record answer
        let answer = AnswerRecord(
            questionId: question.id,
            selectedIndex: selectedIndex,
            isCorrect: isCorrect,
            timeSpent: timeSpent
        )
        answers.append(answer)
        
        // Check if session complete
        if currentQuestionIndex >= questionsPerSession - 1 {
            completeSession()
        } else {
            // Small delay before next question
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.loadNextQuestion()
            }
        }
    }
    
    func pauseSession() {
        guard isSessionActive && !isPaused else { return }
        isPaused = true
        stopTimer()
    }
    
    func resumeSession() {
        guard isSessionActive && isPaused else { return }
        isPaused = false
        startTimer()
    }
    
    func endSession() {
        completeSession()
    }
    
    // MARK: - Private Methods
    private func loadNextQuestion() {
        guard currentQuestionIndex < sessionQuestions.count else { return }
        
        currentQuestion = sessionQuestions[currentQuestionIndex]
        currentQuestionIndex += 1
        questionStartTime = Date()
        timeRemaining = secondsPerQuestion
        
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                // Time's up - auto submit with wrong answer
                self.submitAnswer(selectedIndex: -1)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func completeSession() {
        guard let startTime = sessionStartTime,
              let category = sessionQuestions.first?.category else { return }
        
        stopTimer()
        isSessionActive = false
        
        // Calculate results
        let correctCount = answers.filter { $0.isCorrect }.count
        let totalTime = Date().timeIntervalSince(startTime)
        
        // Calculate XP
        let xpBreakdown = xpCalculator.calculateXP(
            correctAnswers: correctCount,
            totalQuestions: questionsPerSession,
            averageTimePerQuestion: totalTime / Double(questionsPerSession),
            currentStreak: currentStreak,
            category: category
        )
        
        // Create session result
        sessionResult = SessionResult(
            category: category,
            correctCount: correctCount,
            totalQuestions: questionsPerSession,
            xpEarned: xpBreakdown.total,
            timeElapsed: totalTime,
            answers: answers,
            streakBonus: xpBreakdown.streakBonus,
            perfectBonus: xpBreakdown.perfectBonus
        )
    }
    
    private func resetSession() {
        currentQuestion = nil
        currentQuestionIndex = 0
        sessionQuestions = []
        answers = []
        timeRemaining = secondsPerQuestion
        isSessionActive = false
        isPaused = false
        sessionResult = nil
        currentStreak = 0
        sessionStartTime = nil
        questionStartTime = nil
        stopTimer()
    }
    
    deinit {
        stopTimer()
    }
}

// MARK: - Error Types
enum QuizError: LocalizedError {
    case insufficientQuestions
    case sessionNotActive
    case questionLoadFailed
    
    var errorDescription: String? {
        switch self {
        case .insufficientQuestions:
            return String(localized: "error.insufficient_questions")
        case .sessionNotActive:
            return String(localized: "error.session_not_active")
        case .questionLoadFailed:
            return String(localized: "error.question_load_failed")
        }
    }
}
