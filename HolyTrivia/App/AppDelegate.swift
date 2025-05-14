// AppDelegate.swift
import UIKit
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Verificar archivos de preguntas
        PersistenceManager.shared.checkAvailableQuestionFiles()
        
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                        print("Failed to set up audio session: \(error)")
                    }
                    
                    // Redirigir logs a archivo para ayudar con depuración
                    redirectLogsToFile()
                    
                    return true
                }
                
                func redirectLogsToFile() {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let logPath = documentsPath.appending("/holytrivia.log")
                    
                    print("Redirigiendo logs a: \(logPath)")
                    
                    // Intentar abrir el archivo para escritura
                    freopen(logPath.cString(using: .ascii), "a+", stderr)
                }
            }
