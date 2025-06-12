// Presentation/Screens/Quiz/QuizViewModel.swift

import SwiftUI
import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var currentQuestionIndex: Int = 0
    @Published private(set) var timeRemaining: TimeInterval = 30
    @Published private(set) var score: Int = 0
    @Published private(set) var isSessionActive: Bool = false
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var isProcessingAnswer: Bool = false
    @Published private(set) var sessionResult: SessionResult?
    @Published private(set) var lastAnswerWasCorrect: Bool?
    @Published private(set) var currentStreak: Int = 0
    
    // MARK: - Private Properties
    private var quizEngine: QuizEngine?
    private var soundManager: SoundManager?
    private var hapticManager: HapticManager?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func startQuiz(
        category: Category,
        quizEngine: QuizEngine,
        soundManager: SoundManager,
        hapticManager: HapticManager
    ) async {
        self.quizEngine = quizEngine
        self.soundManager = soundManager
        self.hapticManager = hapticManager
        
        setupBindings()
        
        do {
            try await quizEngine.startSession(category: category)
            isLoading = false
        } catch {
            print("Failed to start quiz: \(error)")
            isLoading = false
        }
    }
    
    func submitAnswer(index: Int) {
        guard !isProcessingAnswer else { return }
        
        isProcessingAnswer = true
        lastAnswerWasCorrect = nil
        
        // Play tap haptic
        hapticManager?.playButtonTap()
        
        // Check if answer is correct
        if let question = currentQuestion {
            let isCorrect = index == question.correctIndex
            lastAnswerWasCorrect = isCorrect
            
            // Play feedback
            if isCorrect {
                soundManager?.play(.correct)
                hapticManager?.playCorrectAnswer()
            } else {
                soundManager?.play(.incorrect)
                hapticManager?.playIncorrectAnswer()
            }
            
            // Submit to engine
            quizEngine?.submitAnswer(selectedIndex: index)
            
            // Reset after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.lastAnswerWasCorrect = nil
                self.isProcessingAnswer = false
            }
        }
    }
    
    func pauseQuiz() {
        quizEngine?.pauseSession()
    }
    
    func resumeQuiz() {
        quizEngine?.resumeSession()
    }
    
    func endQuiz() {
        quizEngine?.endSession()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        guard let quizEngine = quizEngine else { return }
        
        // Bind quiz engine properties
        quizEngine.$currentQuestion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] question in
                self?.currentQuestion = question
            }
            .store(in: &cancellables)
        
        quizEngine.$currentQuestionIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.currentQuestionIndex = index
            }
            .store(in: &cancellables)
        
        quizEngine.$timeRemaining
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.timeRemaining = time
                
                // Play countdown sound for last 5 seconds
                if time <= 5 && time > 4.9 {
                    self?.soundManager?.play(.countdown)
                    self?.hapticManager?.playCountdown()
                }
            }
            .store(in: &cancellables)
        
        quizEngine.$isSessionActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.isSessionActive = isActive
            }
            .store(in: &cancellables)
        
        quizEngine.$sessionResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let result = result else { return }
                self?.sessionResult = result
                
                // Play completion sound
                if result.isPerfect {
                    self?.soundManager?.play(.perfect)
                } else {
                    self?.soundManager?.play(.levelUp)
                }
                self?.hapticManager?.playLevelUp()
            }
            .store(in: &cancellables)
        
        quizEngine.$currentStreak
            .receive(on: DispatchQueue.main)
            .sink { [weak self] streak in
                let previousStreak = self?.currentStreak ?? 0
                self?.currentStreak = streak
                
                // Play streak sound when reaching milestone
                if streak > previousStreak && streak % 5 == 0 {
                    self?.soundManager?.play(.streak)
                    self?.hapticManager?.playStreakBonus()
                }
            }
            .store(in: &cancellables)
        
        // Calculate score from answers
        quizEngine.$answers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] answers in
                self?.score = answers.filter { $0.isCorrect }.count * 10
            }
            .store(in: &cancellables)
    }
}
