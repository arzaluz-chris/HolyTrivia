// Core/Utilities/SoundManager.swift

import AVFoundation
import SwiftUI

@MainActor
final class SoundManager: ObservableObject {
    // MARK: - Published Properties
    @AppStorage("soundEffectsEnabled") var soundEffectsEnabled = true
    @Published private(set) var isInitialized = false
    
    // MARK: - Private Properties
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: - Sound Effects
    enum SoundEffect: String, CaseIterable {
        case correct = "correct"
        case incorrect = "incorrect"
        case levelUp = "levelup"
        case countdown = "countdown"
        case streak = "streak"
        case perfect = "perfect"
        
        var volume: Float {
            switch self {
            case .correct, .incorrect:
                return 0.6
            case .levelUp, .perfect:
                return 0.8
            case .countdown:
                return 0.4
            case .streak:
                return 0.7
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    func preloadSounds() async {
        for effect in SoundEffect.allCases {
            await loadSound(effect)
        }
        isInitialized = true
    }
    
    func play(_ sound: SoundEffect) {
        guard soundEffectsEnabled else { return }
        
        Task {
            if audioPlayers[sound] == nil {
                await loadSound(sound)
            }
            
            audioPlayers[sound]?.play()
        }
    }
    
    func stopAll() {
        audioPlayers.values.forEach { $0.stop() }
    }
    
    // MARK: - Private Methods
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    @MainActor
    private func loadSound(_ sound: SoundEffect) async {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Sound file not found: \(sound.rawValue)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = sound.volume
            audioPlayers[sound] = player
        } catch {
            print("Failed to load sound \(sound.rawValue): \(error)")
        }
    }
}
