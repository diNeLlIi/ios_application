//
//  level_progression.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-19.
//

import SwiftUI
internal import Combine

struct LitCard: Identifiable {
    let id:Int
    var isLit:Bool = false
}

enum GameLevel: Int, CaseIterable{
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
    
    var litTime: Double{
        switch self {
        case .level1:
            return 1.5
        case .level2:
            return 1.2
        case .level3:
            return 1
        case .level4:
            return 0.2
        }
    }
    
    var glowColor: Color{
        switch self {
        case .level1:
            return .teal
        case .level2:
            return .red
        case .level3:
            return .purple
        case .level4:
            return .green
        }
    }
    
    var levelName: String{
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
    @AppStorage("lightItUpHighestScore") private var highestSocre = 0
    @AppStorage("lightItUpRoundLength") private var roundLength: Double = 60
    
    //game components
    @State private var cards: [LitCard] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var currentLevel: GameLevel = .level1
    //
    //state racking and time tracking
    @State private var elapsedTime: Double = 0
    @State private var timeSinceLastTap: Double
    @State private var isGameOver: Bool = false
    @State private var isGameActive: Bool = false
    
    //UI effects state
    static let darkNavyBlue = Color(red: 0.0, green: 0.1, blue: 0.4)
    @State private var showSettings = false
    //    @State private var isPaused: Bool = false
    @State private var displayLevel = false
    @State private var flashColor: Color = Self.darkNavyBlue
    
    
    //game timer
    let gameTimer = Timer.publish(every: 1, on : .main, in: .common).autoconnect()
    var quarterDuration: Double { roundLength / 4.0 }
    
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                //Header dashboard
                HStack{
                    VStack(alignment: .leading){
                        Text("Score: \(score)")
                            .font(.title2.bold())
                            .foregroundColor(Color.white)
                        
                        Text("High Score: \(highestSocre)")
                            .font(.headline)
                            .foregroundColor(Color (white: 0.7))
                    }
                    Spacer()
                    
                    HStack(spacing: 4){
                        ForEach(0..<3){
                            index in
                            Image(systemName: index < lives ? "heart.fill": "heart")
                                .foregroundColor(.red)
                                .font(.system(size:40))
                        }
                    }
                    
                }
                .foregroundColor(.white).padding()
                
                //current status display
                HStack{
                    Text(currentLevel.levelName).font(.headline).foregroundColor(currentLevel.glowColor)
                    Spacer()
                    
                    Text(String(format: "Time: %.1fs / %.0fs", elapsedTime, roundLength))
                        .font(.subheadline).foregroundColor(.white)
                }
                .padding(.horizontal)
                
                Spacer()
                
                //Active dynamic grid renderer and start, game over menu
                if isGameActive && !isGameOver {
                    let columns = Array(
                        repeating: GridItem(.flexible(),
                                            spacing: 30),
                        count: currentLevel.columnCount
                    )
                    
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(cards){
                            card in RoundedRectangle(cornerRadius: 16)
                                .fill(card.isLit ?  currentLevel.glowColor : Color.white.opacity(0.8))
                                .frame(height: 200)
                            
                                .shadow(color: card.isLit ? currentLevel.glowColor: .clear, radius:card.isLit ? 15 : 0)
                                .scaleEffect(card.isLit ? 1.1 : 1)
                                .onTapGesture {
//                                    handleTap(on: card)
                                }
                        }
                        .padding(25)
                        .transition(.opacity)
                    }
                }
                else{
                    VStack(spacing: 20) {
                        Text(isGameOver ? (lives == 0 ? "Game Over!" : "Time's Up!") : "Light It Up")
                            .font(.largeTitle.bold())
                            .foregroundColor(isGameOver ? .red : .blue)
                        
                        if isGameOver { Text("Final Score: \(score)").font(.title2).foregroundColor(.white) }
                        
//                        Button(action: startGame()) {
//                            Text(isGameOver ? "Play Again" : "Start Game")
//                                .font(.headline).foregroundColor(.black)
//                                .padding().frame(width: 200).background(Color.white).cornerRadius(10)
//                        }
                    }
                }
                Spacer()
                
                //Level transition
            }
            
            if displayLevel { flashColor.opacity(0.3).ignoresSafeArea().transition(.opacity) }
        }
//        .onReceive(gameTimer) { _ in runTickLoop() }
        
        
    }
    
    
    
}


#Preview {
//    LightItUpView()
}

