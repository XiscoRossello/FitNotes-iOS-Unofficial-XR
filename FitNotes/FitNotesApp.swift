//
//  FitNotesApp.swift
//  FitNotes
//
//  Created by xiscorossello on 22/12/2023.
//

import SwiftUI
import SwiftData
import UserNotifications
import AudioToolbox
import UIKit

@main
struct FitNotesApp: App {
    @StateObject private var restTimerManager = RestTimerManager()
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(restTimerManager)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                    }
                }
        }
        .modelContainer(AppModelContainer)
    }
}

@MainActor
final class RestTimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var remainingSeconds = 0
    @Published var exerciseName = ""

    private var timer: Timer?
    private let completionNotificationId = "fitnotes.restTimer.completed"
    private var alertMode: RestAlertMode = .soundAndVibration

    func start(seconds: Int, exerciseName: String, alertMode: RestAlertMode) {
        guard seconds > 0 else {
            stop()
            return
        }

        stop()
        self.exerciseName = exerciseName
        self.alertMode = alertMode
        remainingSeconds = seconds
        isRunning = true
        isPaused = false

        scheduleCompletionNotification(seconds: seconds, exerciseName: exerciseName, alertMode: alertMode)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            }
            if self.remainingSeconds <= 0 {
                self.triggerInAppCompletionAlert()
                self.stop(clearNotification: false)
            }
        }
    }

    func pause() {
        guard isRunning else { return }
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = remainingSeconds > 0
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [completionNotificationId])
    }

    func resume() {
        guard isPaused, remainingSeconds > 0 else { return }
        isRunning = true
        isPaused = false
        scheduleCompletionNotification(seconds: remainingSeconds, exerciseName: exerciseName, alertMode: alertMode)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            }
            if self.remainingSeconds <= 0 {
                self.triggerInAppCompletionAlert()
                self.stop(clearNotification: false)
            }
        }
    }

    func adjust(by delta: Int) {
        let updated = max(0, remainingSeconds + delta)
        remainingSeconds = updated

        if updated == 0 {
            stop()
            return
        }

        if isRunning {
            scheduleCompletionNotification(seconds: updated, exerciseName: exerciseName, alertMode: alertMode)
        }
    }

    func stop(clearNotification: Bool = true) {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        remainingSeconds = 0

        if clearNotification {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [completionNotificationId])
        }
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func scheduleCompletionNotification(seconds: Int, exerciseName: String, alertMode: RestAlertMode) {
        let content = UNMutableNotificationContent()
        content.title = "Rest finished"
        content.body = "Continue \(exerciseName)."
        content.sound = alertMode.includesSound ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: completionNotificationId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [completionNotificationId])
        UNUserNotificationCenter.current().add(request)
    }

    private func triggerInAppCompletionAlert() {
        if alertMode.includesVibration {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        if alertMode.includesSound {
            AudioServicesPlaySystemSound(1005)
        }
    }
}
