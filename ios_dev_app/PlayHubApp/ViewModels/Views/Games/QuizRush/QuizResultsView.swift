//
//  QuizResultsView.swift
//  ios_dev_app
//

import SwiftUI

struct QuizResultsView: View {
    let score: Int
    let difficulty: QuizDifficulty
    let category: TriviaCategory    
    let onPlayAgain: () -> Void

    @State private var showScore = false

    private var maxScore: Int {
        10 * (difficulty.pointsPerCorrect + difficulty.streakBonus)
    }

    private var shareText: String {
        "I just scored \(score)/\(maxScore) on Quiz Rush (\(difficulty.displayName) · \(category.name)) — beat that! 🧠🔥"
    }

    var body: some View {
        ZStack {
            ConfettiView()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                Text("Round Complete!")
                    .font(.largeTitle.bold())

                // Score display
                Text("\(score)")
                    .font(.system(size: 72, weight: .black))
                    .foregroundColor(difficulty.color)
                    .scaleEffect(showScore ? 1 : 0.3)
                    .opacity(showScore ? 1 : 0)

                Text("out of \(maxScore) points")
                    .font(.title3)
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: difficulty.icon)
                        .foregroundColor(difficulty.color)
                    Text(difficulty.displayName)
                        .foregroundColor(difficulty.color)
                    Text("·").foregroundColor(.secondary)
                    Image(systemName: category.icon)
                        .foregroundColor(.secondary)
                    Text(category.name)
                        .foregroundColor(.secondary)
                }
                .font(.caption.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())

                ShareLink(item: shareText) {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)

                Button("Play Again") {
                    onPlayAgain()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(difficulty.color)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                showScore = true
            }
        }
    }
}
