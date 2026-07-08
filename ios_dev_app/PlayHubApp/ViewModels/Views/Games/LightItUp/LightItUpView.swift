//
//  LightItUpView.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine

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
                            colors: [.blue, .black],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.1)
                    .offset(y: isAnimating ? 0 : 500)
                
                Text("Light It Up!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }
            .onTapGesture {
                navigateToNext = true
            }
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    isAnimating = true
                }
            }
            .navigationDestination(isPresented: $navigateToNext) {
                LightItUpView()
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            navigateToNext = true
                        }
                    }
            )
        }
    }
}


struct LightItUpView: View {
    @StateObject private var vm = LightItUpVM()
    let gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // Header dashboard
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(vm.score)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("High Score: \(vm.highestScore)")
                            .font(.headline)
                            .foregroundColor(Color(white: 0.7))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < vm.lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.system(size: 28))
                        }
                    }
                }
                .padding()

                HStack {
                    Text(vm.currentLevel.levelName)
                        .font(.headline)
                        .foregroundColor(vm.currentLevel.glowColor)
                    Spacer()
                    Text(String(format: "%.1fs / %.0fs", vm.elapsedTime, vm.roundLength))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Spacer()

                if vm.isGameActive && !vm.isGameOver {
                    let columns = Array(
                        repeating: GridItem(.flexible(), spacing: 24),
                        count: vm.currentLevel.columnCount
                    )
                    
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(vm.cards) { card in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(card.isLit ? vm.currentLevel.glowColor : Color.white.opacity(0.15))
                                .frame(height: vm.currentLevel.cardHeight)
                                .shadow(color: card.isLit ? vm.currentLevel.glowColor : .clear,
                                        radius: card.isLit ? 15 : 0)
                                .scaleEffect(card.isLit ? 1.08 : 1.0)
                                .animation(.easeInOut(duration: 0.15), value: card.isLit)
                                .onTapGesture { vm.handleTap(on: card) }
                        }
                    }
                    .padding(30)
                    .transition(.opacity)

                } else {
                    VStack(spacing: 20) {
                        Text(vm.isGameOver ? (vm.lives == 0 ? "Game Over!" : "Time's Up!") : "Light It Up")
                            .font(.largeTitle.bold())
                            .foregroundColor(vm.isGameOver ? .red : .blue)

                        if vm.isGameOver {
                            Text("Final Score: \(vm.score)")
                                .font(.title2)
                                .foregroundColor(.white)
                        }

                        Button(action: { vm.startGame() }) {
                            Text(vm.isGameOver ? "Play Again" : "Start Game")
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

            if vm.displayLevel {
                vm.flashColor.opacity(0.3).ignoresSafeArea().transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(gameTimer) { _ in
            vm.runTickLoop()
        }
    }
}

#Preview {
    Light()
}
