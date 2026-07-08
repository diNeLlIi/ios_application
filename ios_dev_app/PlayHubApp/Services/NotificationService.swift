//
//  NotificationService.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Notification setup failed: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDailyChallenge(at date: Date) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge! 🎮"
        content.body = "It's time to beat your high score. Open PlayHub now!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily.challenge", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
