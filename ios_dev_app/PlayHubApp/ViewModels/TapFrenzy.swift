//
//  TapFrenzy.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine

class TapFrenzyVM: ObservableObject {
    @Published var tapCount: Int = 0
    @Published var timeRemaining: Int = 10
    @Published var isGameActive: Bool = false
    @Published var isGameOver: Bool = false
    @Published var circleScale: CGFloat = 1.0
    @Published var showAlert: Bool = false
    
    let timeLimit: Int = 10
    
    func handleTap() {
        tapCount += 1
        circleScale = 0.88
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.circleScale = 1.0
        }
    }
    
    func startGame() {
        tapCount = 0
        timeRemaining = timeLimit
        isGameOver = false
        isGameActive = true
    }
    
    func resetGame() {
        isGameActive = false
        isGameOver = false
        tapCount = 0
        timeRemaining = timeLimit
        showAlert = false
        circleScale = 1.0
    }
    
    func timerTick() {
        guard isGameActive else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            isGameActive = false
            isGameOver = true
            showAlert = true
        }
    }
}
