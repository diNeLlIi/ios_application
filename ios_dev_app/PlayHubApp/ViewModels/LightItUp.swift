//
//  LightItUp.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine

class LightItUpVM: ObservableObject {
    @AppStorage("lightItUpHighestScore") var highestScore = 0
    @AppStorage("lightItUpRoundLength") var roundLength: Double = 60

    @Published var cards: [LitCard] = []
    @Published var score = 0
    @Published var lives = 3
    @Published var currentLevel: GameLevel = .level1

    @Published var elapsedTime: Double = 0
    @Published var timeSinceLastCycle: Double = 0
    @Published var isGameOver: Bool = false
    @Published var isGameActive: Bool = false

    @Published var displayLevel = false
    @Published var flashColor: Color = Color(red: 0.0, green: 0.1, blue: 0.4)

    var quarterDuration: Double { roundLength / 4.0 }
    
    func startGame() {
        score = 0
        lives = 3
        elapsedTime = 0
        timeSinceLastCycle = 0
        isGameOver = false
        isGameActive = true
        currentLevel = .level1
        buildGrid(for: .level1)
    }
    
    func handleTap(on card: LitCard) {
        guard isGameActive, !isGameOver else { return }
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[idx].isLit {
            withAnimation(.easeOut(duration: 0.15)) { cards[idx].isLit = false }
            score += 10
            if score > highestScore { highestScore = score }
        } else {
            deductLife()
        }
    }

    func runTickLoop() {
        elapsedTime += 0.1
        timeSinceLastCycle += 0.1

        let newLevel: GameLevel
        if elapsedTime < quarterDuration { newLevel = .level1 }
        else if elapsedTime < quarterDuration * 2 { newLevel = .level2 }
        else if elapsedTime < quarterDuration * 3 { newLevel = .level3 }
        else { newLevel = .level4 }

        if newLevel != currentLevel {
            currentLevel = newLevel
            timeSinceLastCycle = 0
            buildGrid(for: newLevel)
            showLevelFlash()
        }

        if timeSinceLastCycle >= currentLevel.litTime {
            timeSinceLastCycle = 0
            cycleLitCards()
        }

        if elapsedTime >= roundLength { endGame() }
    }

    func cycleLitCards() {
        for card in cards where card.isLit {
            deductLife()
            if isGameOver { return }
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
        if lives <= 0 { endGame() }
    }

    func endGame() {
        for i in cards.indices { cards[i].isLit = false }
        isGameActive = false
        isGameOver = true
        if score > highestScore { highestScore = score }
    }

    func showLevelFlash() {
        flashColor = currentLevel.glowColor
        withAnimation(.easeIn(duration: 0.1)) { displayLevel = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) { self.displayLevel = false }
        }
    }
}
