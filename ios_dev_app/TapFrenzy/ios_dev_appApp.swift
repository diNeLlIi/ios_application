//
//  ios_dev_appApp.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-06.
//

import SwiftUI
internal import Combine


struct ContentView: View {
    @State private var tapCount: Int = 0
    @State private var timeRemaining: Int = 10
    @State private var isGameActive: Bool = false
    @State private var isGameOver: Bool = false
    @State private var circleScale: CGFloat = 1.0
    @State private var showAlert: Bool = false

    let timeLimit: Int = 10

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            //background image
            Image("background-wood-cartoon")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                //Tap Counter
                Text("Tap Counter")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 30)

               //tap count
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 220, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 3)
                        )

                    VStack(spacing: 4) {
                        Text("TAP COUNT")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                            .tracking(2)
                        Text("\(tapCount)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 10)

                Spacer()

                //tap button
                Button(action: handleTap) {
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 4)
                            .frame(width: 200, height: 200)

                        Circle()
                            .fill(isGameActive
                                  ? Color.orange.opacity(0.9)
                                  : Color.white.opacity(0.6))
                            .frame(width: 190, height: 190)

                        VStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 40))
                                .foregroundColor(isGameActive ? .white : .gray)
                            Text("TAP")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(isGameActive ? .white : .gray)
                        }
                    }
                }
                .scaleEffect(circleScale)
                .disabled(!isGameActive)
                .animation(.spring(response: 0.15, dampingFraction: 0.5), value: circleScale)

                Spacer()

                //time remaining
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 220, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 3)
                        )

                    VStack(spacing: 4) {
                        Text("TIME REMAINING")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                            .tracking(2)
                        Text("\(timeRemaining)s")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(
                                timeRemaining <= 3 && isGameActive ? .red : .black
                            )
                    }
                }
                .padding(.top, 10)

                Button(action: isGameOver ? resetGame : startGame) {
                    Text(isGameOver ? "Play Again" : (isGameActive ? "Running..." : "Start"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 160, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(isGameActive ? Color.gray.opacity(0.6) : Color.brown)
                        )
                }
                .disabled(isGameActive)
                .padding(.top, 20)
                .padding(.bottom, 50)
            }
        }

        .onReceive(timer) { _ in
            guard isGameActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isGameActive = false
                isGameOver = true
                showAlert = true
            }
        }

        .alert("Game Over!", isPresented: $showAlert) {
            Button("OK") {
                resetGame()
            }
        } message: {
            Text("You tapped \(tapCount) time\(tapCount == 1 ? "" : "s") in \(timeLimit) seconds!")
        }
    }

    private func handleTap() {
        tapCount += 1
        circleScale = 0.88
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            circleScale = 1.0
        }
    }

    private func startGame() {
        tapCount = 0
        timeRemaining = timeLimit
        isGameOver = false
        isGameActive = true
    }

    private func resetGame() {
        isGameActive = false
        isGameOver = false
        tapCount = 0
        timeRemaining = timeLimit
        showAlert = false
        circleScale = 1.0
    }
}


#Preview {
    ContentView()
}
