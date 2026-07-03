import SwiftUI

struct QuizResultsView: View {
    let score: Int
    let onPlayAgain: () -> Void

    @State private var showScore = false

    var body: some View {
        ZStack {
            ConfettiView()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                Text("Round Complete!")
                    .font(.largeTitle.bold())

                Text("\(score)")
                    .font(.system(size: 72, weight: .black))
                    .foregroundColor(.orange)
                    .scaleEffect(showScore ? 1 : 0.3)
                    .opacity(showScore ? 1 : 0)

                Text("points")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Button("Play Again") {
                    onPlayAgain()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
                showScore = true
            }
        }
    }
}
