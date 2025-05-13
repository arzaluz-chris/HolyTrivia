// TimerManager.swift
import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning = false
    @Published var progress: Double = 1.0
    
    private var timer: AnyCancellable?
    private var initialTime: TimeInterval
    private var completionHandler: (() -> Void)?
    
    init(timeInterval: TimeInterval = 15) {
        self.initialTime = timeInterval
        self.timeRemaining = timeInterval
    }
    
    func start(completion: (() -> Void)? = nil) {
        self.completionHandler = completion
        isRunning = true
        progress = 1.0
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.1
                    self.progress = self.timeRemaining / self.initialTime
                } else {
                    self.stop()
                    self.completionHandler?()
                }
            }
    }
    
    func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func reset() {
        stop()
        timeRemaining = initialTime
        progress = 1.0
    }
    
    func setTimeInterval(_ interval: TimeInterval) {
        initialTime = interval
        reset()
    }
}
