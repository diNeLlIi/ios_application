//
//  LightItUp.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine

class LightItUpVM: ObservableObject {
    @Published var cards: [LitCard] = []
    @Published var score = 0
    @Published var lives = 3
    @Published var currentLevel: GameLevel = .level1
    @Published var currentLevelHighScore = 0
    @Published var elapsedTime: Double = 0
    @Published var timeSinceLastCycle: Double = 0
    @Published var isGameActive: Bool = false
    @Published var showPopup: Bool = false
    @Published var levelWon: Bool = false
    @Published var displayLevel = false
    @Published var flashColor: Color = Color(red: 0.0, green: 0.1, blue: 0.4)

    private var timerCancellable: AnyCancellable?
    
    func startLevel(_ level: GameLevel) {
        currentLevel = level
        score = 0
        lives = 3
        elapsedTime = 0
        timeSinceLastCycle = 0
        
        showPopup = false
        levelWon = false
        
        currentLevelHighScore = UserDefaults.standard.integer(forKey: level.highscoreStorageKey)
        
        buildGrid(for: level)
        showLevelFlash()
        
        isGameActive = true
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.runTickLoop()
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    func handleTap(on card: LitCard) {
        guard isGameActive else { return }
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[idx].isLit {
            withAnimation(.easeOut(duration: 0.15)) { cards[idx].isLit = false }
            
            // Scaled dynamic scoring
            score += currentLevel.pointsPerTap
            
            if score > currentLevelHighScore {
                currentLevelHighScore = score
                UserDefaults.standard.set(score, forKey: currentLevel.highscoreStorageKey)
            }
        } else {
            deductLife()
        }
    }

    func runTickLoop() {
        guard isGameActive else { return }
        
        elapsedTime += 0.1
        timeSinceLastCycle += 0.1

        if timeSinceLastCycle >= currentLevel.litTime {
            timeSinceLastCycle = 0
            cycleLitCards()
        }

        if elapsedTime >= currentLevel.duration {
            let won = score >= currentLevel.unlockThreshold
            endLevel(won: won)
        }
    }

    func cycleLitCards() {
        for card in cards where card.isLit {
            deductLife()
            if !isGameActive { return }
        }
        
        withAnimation(.easeIn(duration: 0.1)) {
            for i in cards.indices { cards[i].isLit = false }
        }
        
        let howMany = min(currentLevel.litCount, cards.count)
        let chosen = cards.indices.shuffled().prefix(howMany)
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            for i in chosen { cards[i].isLit = true }
        }
    }

    func buildGrid(for level: GameLevel) {
        withAnimation(.easeInOut(duration: 0.25)) {
            cards = (0..<level.totalCount).map { LitCard(id: $0) }
        }
    }

    func deductLife() {
        lives -= 1
        if lives <= 0 { endLevel(won: false) }
    }

    func endLevel(won: Bool) {
        stopTimer()
        isGameActive = false
        levelWon = won
        
        for i in cards.indices { cards[i].isLit = false }
        
        if score > currentLevelHighScore {
            UserDefaults.standard.set(score, forKey: currentLevel.highscoreStorageKey)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                self.showPopup = true
            }
        }
    }

    func showLevelFlash() {
        flashColor = currentLevel.glowColor
        withAnimation(.easeIn(duration: 0.1)) { displayLevel = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) { self.displayLevel = false }
        }
    }
}
