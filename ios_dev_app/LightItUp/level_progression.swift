//
//  level_progression.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-19.
//

import SwiftUI
internal import Combine

struct LitCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

enum GameLevel: Int, CaseIterable {
    case level1, level2, level3, level4
    
    var columnCount:Int{
        switch self {
        case .level1:
            return 1
        case .level2:
            return 2
        case .level3:
            return 2
        case .level4:
            return 3
        }
    }
    
    var totalCount: Int{
        switch self {
        case .level1:
            return 3
        case .level2:
            return 4
        case .level3:
            return 6
        case .level4:
            return 9
        }
    }

    var litCount: Int { self == .level4 ? 2 : 1 }

    var litTime: Double {
        switch self {
        case .level1:
            return 1.5
        case .level2:
            return 1.2
        case .level3:
            return 1.0
        case .level4:
            return 0.8
        }
    }

    var cardHeight: CGFloat {
        switch self {
        case .level1:
            return 140
        case .level2:
            return 120
        case .level3:
            return 100
        case .level4:
            return 80
        }
    }

    var glowColor: Color {
        switch self {
        case .level1:
            return .teal
        case .level2:
            return .blue
        case .level3:
            return .purple
        case .level4:
            return .green
        }
    }

    var levelName: String {
        switch self {
        case .level1: 
            return "Level 1"
        case .level2: 
            return "Level 2"
        case .level3: 
            return "Level 3"
        case .level4:
            return "Level 4"
        }
    }
}

struct LightItUpView: View {
    @AppStorage("lightItUpHighestScore") private var highestScore = 0
    @AppStorage("lightItUpRoundLength")  private var roundLength: Double = 60

    @State private var cards: [LitCard] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var currentLevel: GameLevel = .level1

    @State private var elapsedTime: Double = 0
    @State private var timeSinceLastCycle: Double = 0
    @State private var isGameOver: Bool = false
    @State private var isGameActive: Bool = false

    static let darkNavyBlue = Color(red: 0.0, green: 0.1, blue: 0.4)
    @State private var showSettings = false
    @State private var displayLevel = false
    @State private var flashColor: Color = Self.darkNavyBlue

    let gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var quarterDuration: Double { roundLength / 4.0 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // Header dashboard
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(score)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("High Score: \(highestScore)")
                            .font(.headline)
                            .foregroundColor(Color(white: 0.7))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.system(size: 28))
                        }
                    }
                }
                .padding()

                HStack {
                    Text(currentLevel.levelName)
                        .font(.headline)
                        .foregroundColor(currentLevel.glowColor)
                    Spacer()
                    Text(String(format: "%.1fs / %.0fs", elapsedTime, roundLength))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Spacer()

                if isGameActive && !isGameOver {
                    let columns = Array(
                        repeating: GridItem(.flexible(), spacing: 24),  // increased from 16
                        count: currentLevel.columnCount
                    )
                    LazyVGrid(columns: columns, spacing: 24) {           // increased from 16
                        ForEach(cards) { card in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(card.isLit ? currentLevel.glowColor : Color.white.opacity(0.15))
                                .frame(height: currentLevel.cardHeight)
                                .shadow(color: card.isLit ? currentLevel.glowColor : .clear,
                                        radius: card.isLit ? 15 : 0)
                                .scaleEffect(card.isLit ? 1.08 : 1.0)
                                .animation(.easeInOut(duration: 0.15), value: card.isLit)
                                .onTapGesture { handleTap(on: card) }
                        }
                    }
                    .padding(30)                                         // increased from 25
                    .transition(.opacity)

                } else {
                    VStack(spacing: 20) {
                        Text(isGameOver ? (lives == 0 ? "Game Over!" : "Time's Up!") : "Light It Up")
                            .font(.largeTitle.bold())
                            .foregroundColor(isGameOver ? .red : .blue)

                        if isGameOver {
                            Text("Final Score: \(score)")
                                .font(.title2)
                                .foregroundColor(.white)
                        }

                        Button(action: { startGame() }) {
                            Text(isGameOver ? "Play Again" : "Start Game")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                }

                Spacer()
            }

            if displayLevel {
                flashColor.opacity(0.3).ignoresSafeArea().transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(gameTimer) { _ in
            guard isGameActive && !isGameOver else { return }
            runTickLoop()
        }
    }
    
    // startGame

    func startGame() {
        score              = 0
        lives              = 3
        elapsedTime        = 0
        timeSinceLastCycle = 0
        isGameOver         = false
        isGameActive       = true
        currentLevel       = .level1
        buildGrid(for: .level1)
    }

    //handlle tap
    
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
        elapsedTime        += 0.1
        timeSinceLastCycle += 0.1

        let newLevel: GameLevel
        if      elapsedTime < quarterDuration     { newLevel = .level1 }
        else if elapsedTime < quarterDuration * 2 { newLevel = .level2 }
        else if elapsedTime < quarterDuration * 3 { newLevel = .level3 }
        else                                       { newLevel = .level4 }

        if newLevel != currentLevel {
            currentLevel       = newLevel
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
        let chosen  = cards.indices.shuffled().prefix(howMany)
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
        isGameOver   = true
        if score > highestScore { highestScore = score }
    }

    func showLevelFlash() {
        flashColor = currentLevel.glowColor
        withAnimation(.easeIn(duration: 0.1))  { displayLevel = true  }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) { displayLevel = false }
        }
    }
}

#Preview {
    LightItUpView()
}
