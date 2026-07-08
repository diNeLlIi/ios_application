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
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Challenge")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            if newValue {
                                NotificationService.shared.scheduleDailyChallenge(at: reminderTime)
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { oldValue, newValue in
                                NotificationService.shared.scheduleDailyChallenge(at: newValue)
                            }
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(role: .destructive, action: { showResetAlert = true }) {
                        Text("Reset All Stats")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Stats?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) { statsVM.clearStats() }
            } message: {
                Text("This will permanently delete your high scores and history.")
            }
        }
    }
}

