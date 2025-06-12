// Presentation/Screens/Quiz/QuizView.swift

import SwiftUI

struct QuizView: View {
    let category: Category
    @StateObject private var viewModel = QuizViewModel()
    @EnvironmentObject private var appContainer: AppContainer
    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var showingPauseMenu = false
    @State private var selectedAnswerIndex: Int?
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            theme.colors.background
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.isSessionActive {
                quizContent
            } else if let result = viewModel.sessionResult {
                // Navigate to results
                Color.clear
                    .onAppear {
                        showingResults = true
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingPauseMenu = true }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.colors.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(category.displayName)
                    .font(theme.typography.headline)
            }
        }
        .task {
            await viewModel.startQuiz(
                category: category,
                quizEngine: appContainer.quizEngine,
                soundManager: appContainer.soundManager,
                hapticManager: appContainer.hapticManager
            )
        }
        .sheet(isPresented: $showingPauseMenu) {
            PauseMenuView(
                onResume: {
                    showingPauseMenu = false
                    viewModel.resumeQuiz()
                },
                onQuit: {
                    showingPauseMenu = false
                    dismiss()
                }
            )
            .presentationDetents([.medium])
        }
        .navigationDestination(isPresented: $showingResults) {
            if let result = viewModel.sessionResult {
                ResultsView(sessionResult: result, category: category)
            }
        }
    }
    
    private var quizContent: some View {
        VStack(spacing: theme.spacing.large) {
            // Progress Section
            progressSection
            
            // Question Card
            if let question = viewModel.currentQuestion {
                QuestionCard(question: question)
                    .padding(.horizontal, theme.spacing.medium)
            }
            
            Spacer()
            
            // Answer Buttons
            answersSection
            
            // Score Display
            scoreDisplay
        }
        .padding(.vertical, theme.spacing.medium)
    }
    
    private var progressSection: some View {
        VStack(spacing: theme.spacing.small) {
            // Question counter and timer
            HStack {
                Text(String(localized: "quiz.question_of",
                           defaultValue: "Question \(viewModel.currentQuestionIndex) of 10"))
                    .font(theme.typography.subheadline)
                    .foregroundColor(theme.colors.textSecondary)
                
                Spacer()
                
                TimerView(timeRemaining: viewModel.timeRemaining)
            }
            .padding(.horizontal, theme.spacing.medium)
            
            // Progress bar
            ProgressBar(
                current: viewModel.currentQuestionIndex,
                total: 10
            )
            .padding(.horizontal, theme.spacing.medium)
        }
    }
    
    private var answersSection: some View {
        VStack(spacing: theme.spacing.small) {
            if let question = viewModel.currentQuestion {
                ForEach(question.answers.indices, id: \.self) { index in
                    AnswerButton(
                        text: question.answers[index],
                        isSelected: selectedAnswerIndex == index,
                        // Safely unwrap optional Bool (nil treated as false)
                        isCorrect: (viewModel.lastAnswerWasCorrect ?? false) && index == question.correctIndex,
                        isWrong: (!(viewModel.lastAnswerWasCorrect ?? true)) && selectedAnswerIndex == index,
                        isDisabled: viewModel.isProcessingAnswer
                    ) {
                        selectedAnswerIndex = index
                        viewModel.submitAnswer(index: index)
                    }
                }
            }
        }
        .padding(.horizontal, theme.spacing.medium)
    }
    
    private var scoreDisplay: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(theme.colors.gold)
            
            Text(String(localized: "quiz.score", defaultValue: "Score: \(viewModel.score)"))
                .font(theme.typography.headline)
                .foregroundColor(theme.colors.textPrimary)
        }
        .padding(.horizontal, theme.spacing.large)
        .padding(.vertical, theme.spacing.small)
        .background(theme.colors.gold.opacity(0.1))
        .cornerRadius(theme.cornerRadius.large)
        .padding(.horizontal, theme.spacing.medium)
    }
}
