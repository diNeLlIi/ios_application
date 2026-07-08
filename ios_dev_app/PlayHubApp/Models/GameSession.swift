//
//  GameSession.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import Foundation

struct GameSession: Identifiable, Codable {
    var id = UUID()
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}
