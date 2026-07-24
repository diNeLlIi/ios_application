//
//  SettingsTab.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var statsVM: StatusGame
    @State private var reminderTime = Date()
    @State private var notificationsEnabled = false
    @State private var showResetAlert = false
    @State private var resetTarget: ResetTarget? = nil
    
    enum ResetTarget: Identifiable {
        case all
        case lightItUp
        case quizRush
        case tapFrenzy
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .all: return "All"
            case .lightItUp: return "Light It Up"
            case .quizRush: return "Quiz Rush"
            case .tapFrenzy: return "Tap Frenzy"
            }
        }
        
        var message: String {
            switch self {
            case .all:
                return "Are you sure you want to erase your game history"
            case .lightItUp:
                return "Are you sure you want to erase your Light It Up game history"
            case .quizRush:
                return "Are you sure you want to erase all your Quiz Rush game history"
            case .tapFrenzy:
                return "This will permanently erase your Tap Frenzy records"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section(header: Text("Daily Challenge")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(Color(.green))
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                NotificationService.shared.scheduleDailyChallenge(at: reminderTime)
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { _, newValue in
                                NotificationService.shared.scheduleDailyChallenge(at: newValue)
                            }
                    }
                }
                
              
                Section(header: Text("Clear Game Data")) {
                    Button(action: { triggerReset(.lightItUp) }) {
                        HStack {
                            Label("Light It Up", systemImage: "bolt.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: { triggerReset(.quizRush) }) {
                        HStack {
                            Label("Quiz Rush", systemImage: "checkmark.seal.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: { triggerReset(.tapFrenzy) }) {
                        HStack {
                            Label("Tap Frenzy", systemImage: "hand.tap.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: { triggerReset(.all) }) {
                        HStack {
                            Label("Clear All", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
            }
            
            .navigationTitle("Settings")
            .alert(
                "Reset \(resetTarget?.title ?? "Data")?",
                isPresented: $showResetAlert,
                presenting: resetTarget
            ) { target in
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    executeReset(for: target)
                }
            } message: { target in
                Text(target.message)
            }
        }
    }
    
    
    private func triggerReset(_ target: ResetTarget) {
        resetTarget = target
        showResetAlert = true
    }
        
    private func executeReset(for target: ResetTarget) {
            switch target {
            case .all:
                statsVM.clearStats()
                for i in 0...3 {
                    UserDefaults.standard.removeObject(forKey: "lightItUp_highscore_level_\(i)")
                }
                UserDefaults.standard.removeObject(forKey: "lightItUpHighestScore")
                
            case .lightItUp:
                statsVM.clearSessions(for: .lightItUp)
                for i in 0...3 {
                    UserDefaults.standard.removeObject(forKey: "lightItUp_highscore_level_\(i)")
                }
                UserDefaults.standard.removeObject(forKey: "lightItUpHighestScore")
                
            case .quizRush:
                statsVM.clearSessions(for: .quizRush)
                UserDefaults.standard.removeObject(forKey: "quizRushHighScore")
                
            case .tapFrenzy:
                statsVM.clearSessions(for: .tapFrenzy)
                UserDefaults.standard.removeObject(forKey: "tapFrenzyHighScore")
            }
            
             resetTarget = nil
        }
    
}

