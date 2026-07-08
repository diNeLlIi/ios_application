//
//  QuizDifficulty.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI

enum QuizDifficulty: String, CaseIterable, Identifiable {
    case easy   = "easy"
    case medium = "medium"
    case hard   = "hard"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Moderate"
        case .hard:   return "Hard"
        }
    }

    // points for a correct answer
    var pointsPerCorrect: Int {
        switch self {
        case .easy:   return 5
        case .medium: return 10
        case .hard:   return 15
        }
    }

    // bonus points added when streak >= 3
    var streakBonus: Int {
        switch self {
        case .easy:   return 2
        case .medium: return 5
        case .hard:   return 8
        }
    }

    // points deducted on incorrect answer
    var penalty: Int {
        switch self {
        case .easy:   return 1
        case .medium: return 2
        case .hard:   return 3
        }
    }

    //colour
    var color: Color {
        switch self {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }

    var icon: String {
        switch self {
        case .easy:   return "tortoise.fill"
        case .medium: return "hare.fill"
        case .hard:   return "flame.fill"
        }
    }
}
