// Domain/UseCases/StreakTracker.swift

import Foundation

struct StreakTracker {
    // MARK: - Streak Calculation
    static func calculateStreak(lastPlayedDate: Date?, currentStreak: Int) -> StreakInfo {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastPlayed = lastPlayedDate else {
            return StreakInfo(
                currentStreak: 0,
                shouldResetStreak: false,
                hasPlayedToday: false,
                daysUntilStreakBreak: 1
            )
        }
        
        let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
        let daysSinceLastPlay = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
        
        switch daysSinceLastPlay {
        case 0:
            // Played today
            return StreakInfo(
                currentStreak: currentStreak,
                shouldResetStreak: false,
                hasPlayedToday: true,
                daysUntilStreakBreak: 1
            )
        case 1:
            // Played yesterday - streak continues
            return StreakInfo(
                currentStreak: currentStreak,
                shouldResetStreak: false,
                hasPlayedToday: false,
                daysUntilStreakBreak: 0
            )
        default:
            // Streak broken
            return StreakInfo(
                currentStreak: 0,
                shouldResetStreak: true,
                hasPlayedToday: false,
                daysUntilStreakBreak: 1
            )
        }
    }
    
    // MARK: - Week View
    static func getWeekStreakStatus(lastPlayedDate: Date?, currentStreak: Int) -> [DayStatus] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var weekStatus: [DayStatus] = []
        
        // Get start of week (Sunday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }
        
        // Get played dates for the current streak
        let playedDates = getPlayedDates(from: lastPlayedDate, streak: currentStreak)
        
        // Create status for each day of the week
        for dayOffset in 0..<7 {
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                continue
            }
            
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: currentDate) - 1]
            let isToday = calendar.isDateInToday(currentDate)
            let isFuture = currentDate > today
            let wasPlayed = playedDates.contains { calendar.isDate($0, inSameDayAs: currentDate) }
            
            weekStatus.append(DayStatus(
                date: currentDate,
                dayName: dayName,
                isToday: isToday,
                isFuture: isFuture,
                wasPlayed: wasPlayed
            ))
        }
        
        return weekStatus
    }
    
    // MARK: - Helper Methods
    private static func getPlayedDates(from lastPlayedDate: Date?, streak: Int) -> [Date] {
        guard let lastPlayed = lastPlayedDate, streak > 0 else { return [] }
        
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for i in 0..<streak {
            if let date = calendar.date(byAdding: .day, value: -i, to: lastPlayed) {
                dates.append(calendar.startOfDay(for: date))
            }
        }
        
        return dates
    }
    
    // MARK: - Notification Scheduling
    static func shouldSendStreakReminder(lastPlayedDate: Date?, currentStreak: Int) -> Bool {
        guard currentStreak > 0 else { return false }
        
        let streakInfo = calculateStreak(lastPlayedDate: lastPlayedDate, currentStreak: currentStreak)
        
        // Send reminder if streak is about to break and hasn't played today
        return !streakInfo.hasPlayedToday && streakInfo.daysUntilStreakBreak == 0
    }
    
    static func getStreakMessage(currentStreak: Int, hasPlayedToday: Bool) -> String {
        if currentStreak == 0 {
            return String(localized: "streak.start_new")
        } else if hasPlayedToday {
            return String(localized: "streak.active_today", defaultValue: "🔥 \(currentStreak) day streak!")
        } else {
            return String(localized: "streak.keep_going", defaultValue: "Play today to keep your \(currentStreak) day streak!")
        }
    }
}

// MARK: - Data Models
struct StreakInfo {
    let currentStreak: Int
    let shouldResetStreak: Bool
    let hasPlayedToday: Bool
    let daysUntilStreakBreak: Int
    
    var isAtRisk: Bool {
        currentStreak > 0 && !hasPlayedToday && daysUntilStreakBreak == 0
    }
}

struct DayStatus {
    let date: Date
    let dayName: String
    let isToday: Bool
    let isFuture: Bool
    let wasPlayed: Bool
    
    var displayState: DayDisplayState {
        if isFuture {
            return .future
        } else if wasPlayed {
            return .completed
        } else if isToday {
            return .todayPending
        } else {
            return .missed
        }
    }
    
    enum DayDisplayState {
        case completed
        case todayPending
        case missed
        case future
        
        var backgroundColor: String {
            switch self {
            case .completed:
                return "GreenSuccess"
            case .todayPending:
                return "AccentColor"
            case .missed:
                return "GrayLight"
            case .future:
                return "GrayLight"
            }
        }
        
        var textColor: String {
            switch self {
            case .completed:
                return "White"
            case .todayPending:
                return "White"
            case .missed:
                return "GrayDark"
            case .future:
                return "GrayDark"
            }
        }
    }
}
