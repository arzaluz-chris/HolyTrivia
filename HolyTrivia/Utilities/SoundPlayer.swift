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
            let effectName = effect.rawValue
            
            // Intentar diferentes formas de buscar los archivos de sonido
            if let soundURL = Bundle.main.url(forResource: effectName, withExtension: nil) {
                loadSound(from: soundURL, forEffect: effectName)
            } else if let soundURL = Bundle.main.url(forResource: effectName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") {
                loadSound(from: soundURL, forEffect: effectName)
            } else if let soundURL = Bundle.main.url(forResource: effectName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "wav") {
                loadSound(from: soundURL, forEffect: effectName)
            } else {
                print("No se encontró el archivo de sonido: \(effectName)")
                
                // Usar sonidos de sistema como respaldo
                createGenericSound(for: effectName)
            }
        }
    }
    
    private func loadSound(from url: URL, forEffect effect: String) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[effect] = player
        } catch {
            print("Error cargando sonido \(effect): \(error)")
        }
    }
    
    private func createGenericSound(for effect: String) {
        // Crear sonidos genéricos básicos como respaldo
        let soundID: SystemSoundID = effect.contains("correct") ? 1054 : 1053 // Sonidos del sistema iOS
        
        do {
            // Crear un URL temporal para el sonido del sistema
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(effect).wav")
            
            // Intentar crear un reproductor simple (no funcionará para sonidos del sistema reales)
            let player = try AVAudioPlayer(contentsOf: tempURL)
            audioPlayers[effect] = player
        } catch {
            print("No se pudo crear sonido genérico: \(error)")
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
        } else {
            // Reproducir sonido del sistema como último recurso
            let soundID: SystemSoundID = effect == .correct ? 1054 : 1053
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
