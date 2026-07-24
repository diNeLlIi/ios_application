//
//  LightItUpView.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine
import CoreLocation


struct Light: View {
    @State private var isAnimating = false
    @State private var navigateToNext = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue, .black], center: .center,
                            startRadius: 10, endRadius: 200
                        )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.1)
                    .offset(y: isAnimating ? 0 : 500)
                
                Text("Light It Up!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }
            .onTapGesture { navigateToNext = true }
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    isAnimating = true
                }
            }
            .navigationDestination(isPresented: $navigateToNext) {
                LightItUpLevelsView()
            }
        }
    }
}

//level selector
struct LightItUpLevelsView: View {
    @Environment(\.dismiss) private var dismiss
    let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    private func isUnlocked(_ level: GameLevel) -> Bool {
        if level == .level1 { return true }
        
        guard let prevLevel = GameLevel(rawValue: level.rawValue - 1) else { return false }
        let prevHighScore = UserDefaults.standard.integer(forKey: prevLevel.highscoreStorageKey)
        
        return prevHighScore >= prevLevel.unlockThreshold
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Game Modes")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(GameLevel.allCases, id: \.self) { level in
                            let unlocked = isUnlocked(level)
                            let localHighScore = UserDefaults.standard.integer(forKey: level.highscoreStorageKey)
                            
                            NavigationLink(destination: LightItUpGameplayView(selectedLevel: level)) {
                                VStack(spacing: 12) {
                                    HStack {
                                        Spacer()
                                        if !unlocked {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.gray)
                                                .font(.subheadline)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(localHighScore >= level.unlockThreshold && level.unlockThreshold > 0 ? .green : .clear)
                                                .font(.subheadline)
                                        }
                                    }
                                    .padding(.trailing, 12)
                                    .padding(.top, 8)
                                    
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(unlocked ? level.glowColor : .gray.opacity(0.6))
                                        .shadow(color: unlocked ? level.glowColor.opacity(0.5) : .clear, radius: 8)
                                    
                                    Text(level.levelName)
                                        .font(.headline)
                                        .foregroundColor(unlocked ? .white : .gray)
                                    
                                    // High score display
                                    Text("High: \(localHighScore)")
                                        .font(.caption)
                                        .foregroundColor(unlocked ? .white.opacity(0.6) : .gray.opacity(0.4))
                                    
                                    if level.unlockThreshold > 0 {
                                        Text("Target: \(level.unlockThreshold)")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(unlocked ? level.glowColor.opacity(0.8) : .gray.opacity(0.4))
                                            .padding(.bottom, 8)
                                    } else {
                                        Spacer().frame(height: 12)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .background(unlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.02))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(unlocked ? level.glowColor.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1.5)
                                )
                            }
                            //next level is disabled until the threshold is met
                            .disabled(!unlocked)
                            .opacity(unlocked ? 1.0 : 0.45)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct LevelProgressBar: View {
    let current: Int
    let target: Int
    let color: Color
    let subtitle: String
    
    private var fraction: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(min(Double(current) / Double(target), 1.0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
      
                        .frame(
                            width: max(fraction * geo.size.width, current > 0 ? 8 : 0),
                            height: 10
                        )
                        .shadow(color: color.opacity(0.6), radius: 5)
                        .animation(.easeOut(duration: 0.2), value: fraction)
                }
             
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 10)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


//countdown

struct LightItUpGameplayView: View {
let selectedLevel: GameLevel
@StateObject private var vm = LightItUpVM()
@Environment(\.dismiss) private var dismiss
@EnvironmentObject var statusGame: StatusGame
@EnvironmentObject var locationService: LocationService

private var progressSubtitle: String {
    let target = vm.currentLevel.progressTarget
    if vm.currentLevel.unlockThreshold > 0 {
        return "\(vm.score)"
    } else {
        return "\(vm.score) / \(target) taps · final level"
    }
}

private var popupTitle: String {
    if vm.levelWon {
        return vm.currentLevel.nextLevel == nil ? "You Beat It!" : "Level Completed!"
    } else {
        return "So Close!"
    }
}

//private var popupSubtitle: String {
//    if vm.levelWon {
//        return vm.currentLevel.nextLevel == nil
//            ? "You've conquered the final level. Legendary reflexes."
//            : "Nice reflexes — you're ready for the next challenge."
//    } else {
//        return "You needed \(vm.currentLevel.progressTarget) taps to clear this level."
//    }
//}

var body: some View {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 15) {
            // Top controls bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.leading)
                }
                Spacer()
            }
            .padding(.top, 10)
            

            HStack(alignment: .center) {
                Text(vm.currentLevel.levelName)
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundColor(vm.currentLevel.glowColor)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < vm.lives ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.system(size: 26))
                            .shadow(color: index < vm.lives ? .red.opacity(0.4) : .clear, radius: 5)
                    }
                }
            }
            .padding(.horizontal)
            
            
            HStack(spacing: 12) {
                LevelProgressBar(
                    current: vm.score,
                    target: vm.currentLevel.progressTarget,
                    color: vm.currentLevel.glowColor,
                    subtitle: progressSubtitle
                )
                TimerRing(
                    timeRemaining: max(0, vm.currentLevel.duration - vm.elapsedTime),
                    total: vm.currentLevel.duration
                )
            }
            .padding(.horizontal)
            
//            VStack(spacing: 6) {
//                let total = vm.currentLevel.duration
//                let remaining = max(0, total - vm.elapsedTime)
//                let progressFraction = remaining / total
//                
//                GeometryReader { geo in
//                    ZStack(alignment: .leading) {
//                        Capsule()
//                            .fill(Color.white.opacity(0.1))
//                            .frame(height: 10)
//                        
//                        Capsule()
//                            .fill(
//                                LinearGradient(
//                                    colors: [vm.currentLevel.glowColor, vm.currentLevel.glowColor.opacity(0.6)],
//                                    startPoint: .leading, endPoint: .trailing
//                                )
//                            )
//                            .frame(width: geo.size.width * CGFloat(progressFraction), height: 10)
//                            .shadow(color: vm.currentLevel.glowColor.opacity(0.6), radius: 6, x: 0, y: 0)
//                            .animation(.linear(duration: 0.1), value: vm.elapsedTime)
//                    }
//                }
//                .frame(height: 10)
//                .padding(.horizontal)
//                
//                HStack {
//                    Spacer()
//                    Text(String(format: "%.1fs left", remaining))
//                        .font(.system(.caption, design: .monospaced))
//                        .foregroundColor(.white.opacity(0.8))
//                        .padding(.trailing)
//                }
//            }
            
            Spacer()
            
            let columns = Array(
                repeating: GridItem(.flexible(), spacing: 22),
                count: vm.currentLevel.columnCount
            )
            
            LazyVGrid(columns: columns, spacing: 22) {
                ForEach(vm.cards) { card in
                    RoundedRectangle(cornerRadius: 18)
                        .fill(card.isLit ? vm.currentLevel.glowColor : Color.white.opacity(0.12))
                        .frame(height: vm.currentLevel.cardHeight)
                        .shadow(color: card.isLit ? vm.currentLevel.glowColor : .clear, radius: card.isLit ? 18 : 0)
                        .scaleEffect(card.isLit ? 1.06 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: card.isLit)
                        .onTapGesture { vm.handleTap(on: card) }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        
        if vm.displayLevel {
            vm.flashColor.opacity(0.25).ignoresSafeArea().transition(.opacity)
        }
        
        if vm.showPopup {
            Color.black.opacity(0.7).ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (vm.levelWon ? Color.yellow : Color.orange).opacity(0.35),
                                    .clear
                                ],
                                center: .center, startRadius: 0, endRadius: 70
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 84, height: 84)
                        .overlay(
                            Circle().stroke(
                                (vm.levelWon ? Color.yellow : Color.orange).opacity(0.5),
                                lineWidth: 1.5
                            )
                        )
                    
                    Image(systemName: vm.levelWon ? "trophy.fill" : "arrow.counterclockwise")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(vm.levelWon ? .yellow : .orange)
                }
                
                VStack(spacing: 6) {
                    Text(popupTitle)
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundColor(.white)
                    
//                    Text(popupSubtitle)
//                        .font(.system(.footnote, design: .rounded))
//                        .foregroundColor(.white.opacity(0.55))
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 10)
                }
                
                HStack(spacing: 10) {
                    VStack(spacing: 2) {
                        Text("\(vm.score)")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(vm.currentLevel.glowColor)
                        Text("SCORE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                    
                    VStack(spacing: 2) {
                        Text("\(vm.currentLevelHighScore)")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("BEST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                }
                
                HStack(spacing: 14) {
                    Button(action: { dismiss() }) {
                        Text("Exit")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                    }
                    
                    if vm.levelWon, let next = vm.currentLevel.nextLevel {
                        Button(action: { vm.startLevel(next) }) {
                            HStack(spacing: 6) {
                                Text("Next Level")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [vm.currentLevel.glowColor, vm.currentLevel.glowColor.opacity(0.7)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                    } else {
                        Button(action: { vm.startLevel(selectedLevel) }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Retry")
                            }
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(28)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .white.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, 32)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.85).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
        }
    }
    .navigationBarBackButtonHidden(true)
    .onAppear {
        vm.startLevel(selectedLevel)
    }
    .onChange(of: vm.showPopup) { _, isShowing in
        guard isShowing else { return }
        let coord = locationService.currentLocation
        statusGame.saveSession(
            mode: .lightItUp,
            score: vm.score,
            lat: coord?.latitude ?? 0,
            lng: coord?.longitude ?? 0
        )
    }
}
}


