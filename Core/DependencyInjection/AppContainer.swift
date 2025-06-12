// Core/DependencyInjection/AppContainer.swift

import SwiftUI
import SwiftData
import CloudKit

@MainActor
final class AppContainer: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isInitialized = false
    @Published private(set) var initializationError: Error?
    
    // MARK: - Core Services
    lazy var modelContainer: ModelContainer = {
        do {
            let schema = Schema([
                QuestionSD.self,
                PlayerSD.self,
                SessionResultSD.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.yourcompany.holytrivia")
            )
            
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    // MARK: - Repositories
    lazy var questionRepository: QuestionRepositoryProtocol = {
        QuestionRepository(modelContainer: modelContainer)
    }()
    
    lazy var playerRepository: PlayerRepositoryProtocol = {
        PlayerRepository(modelContainer: modelContainer)
    }()
    
    lazy var sessionRepository: SessionRepositoryProtocol = {
        SessionRepository(modelContainer: modelContainer)
    }()
    
    // MARK: - Use Cases
    lazy var quizEngine: QuizEngine = {
        QuizEngine(
            questionRepository: questionRepository,
            xpCalculator: xpCalculator
        )
    }()
    
    lazy var xpCalculator: XPCalculator = {
        XPCalculator()
    }()
    
    lazy var achievementManager: AchievementManager = {
        AchievementManager(playerRepository: playerRepository)
    }()
    
    // MARK: - Managers
    lazy var soundManager: SoundManager = {
        SoundManager()
    }()
    
    lazy var hapticManager: HapticManager = {
        HapticManager()
    }()
    
    lazy var cloudSyncManager: CloudSyncProtocol? = {
        if UserDefaults.standard.bool(forKey: "cloudSyncEnabled") {
            return CloudKitManager(container: CKContainer(identifier: "iCloud.com.yourcompany.holytrivia"))
        }
        return nil
    }()
    
    // MARK: - Current Player
    @Published var currentPlayer: Player?
    
    // MARK: - Initialization
    func initialize() async {
        do {
            // Load or create player
            if let player = try await playerRepository.getCurrentPlayer() {
                currentPlayer = player
            } else {
                // Create new player
                let newPlayer = Player(username: "Player")
                try await playerRepository.createPlayer(newPlayer)
                currentPlayer = newPlayer
            }
            
            // Preload questions if needed
            let questionCount = try await questionRepository.getQuestionCount(for: .oldTestament)
            if questionCount == 0 {
                try await preloadQuestions()
            }
            
            // Initialize managers
            await soundManager.preloadSounds()
            
            isInitialized = true
        } catch {
            initializationError = error
            print("Failed to initialize app: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func preloadQuestions() async throws {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw AppError.questionsFileNotFound
        }
        
        let decoder = JSONDecoder()
        let questionsData = try decoder.decode(QuestionsData.self, from: data)
        
        for question in questionsData.questions {
            try await questionRepository.saveQuestion(question)
        }
    }
}

// MARK: - Supporting Types
private struct QuestionsData: Decodable {
    let questions: [Question]
}

enum AppError: LocalizedError {
    case questionsFileNotFound
    case playerNotFound
    
    var errorDescription: String? {
        switch self {
        case .questionsFileNotFound:
            return "Questions data file not found"
        case .playerNotFound:
            return "Player data not found"
        }
    }
}

// MARK: - Environment Keys
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.self
}

extension EnvironmentValues {
    var appTheme: AppTheme.Type {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

