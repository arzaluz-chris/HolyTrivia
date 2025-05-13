// SoundPlayer.swift
import Foundation
import AVFoundation

class SoundPlayer {
    static let shared = SoundPlayer()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isSoundEnabled = true
    
    enum SoundEffect: String {
        case correct = "correct.mp3"
        case incorrect = "incorrect.mp3"
        case timer = "timer.mp3"
    }
    
    private init() {
        preloadSounds()
        loadSoundSettings()
    }
    
    private func preloadSounds() {
        for effect in [SoundEffect.correct, SoundEffect.incorrect, SoundEffect.timer] {
            if let soundURL = Bundle.main.url(forResource: effect.rawValue, withExtension: nil) {
                do {
                    let player = try AVAudioPlayer(contentsOf: soundURL)
                    player.prepareToPlay()
                    audioPlayers[effect.rawValue] = player
                } catch {
                    print("Error cargando sonido \(effect.rawValue): \(error)")
                }
            } else {
                print("No se encontró el archivo de sonido: \(effect.rawValue)")
            }
        }
    }
    
    private func loadSoundSettings() {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
    }
    
    func toggleSound() {
        isSoundEnabled = !isSoundEnabled
        UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
    }
    
    func isSoundOn() -> Bool {
        return isSoundEnabled
    }
    
    func play(_ effect: SoundEffect) {
        guard isSoundEnabled else { return }
        
        if let player = audioPlayers[effect.rawValue] {
            if player.isPlaying {
                player.stop()
                player.currentTime = 0
            }
            player.play()
        }
    }
}
