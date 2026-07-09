//
//  StatusGame.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine

class StatusGame: ObservableObject {
    @Published var sessions: [GameSession] = []
    private let saveKey = "SavedGameSessions"

    init() {
        loadSessions()
    }

    func saveSession(mode: GameMode, score: Int, lat: Double, lng: Double) {
        let newSession = GameSession(mode: mode, score: score, timestamp: Date(), latitude: lat, longitude: lng)
        sessions.append(newSession)
        persist()
    }

    func deleteSession(_ session: GameSession) {
        sessions.removeAll { $0.id == session.id }
        persist()
    }

    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            sessions = decoded
        }
    }

    func clearStats() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}

