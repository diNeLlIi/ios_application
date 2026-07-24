import SwiftUI

struct QuizQuestionView: View {
    let question: Question
    @ObservedObject var viewModel: QuizRushViewModel

    var body: some View {
        VStack(spacing: 14) {

            GameScoreDisplay(viewModel: viewModel)

            // Difficulty badge
            HStack(spacing: 4) {
                Image(systemName: viewModel.selectedDifficulty.icon)
                Text(viewModel.selectedDifficulty.displayName)
            }
            .font(.caption.bold())
            .foregroundColor(viewModel.selectedDifficulty.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(viewModel.selectedDifficulty.color.opacity(0.15))
            .clipShape(Capsule())

            StreakBadge(streak: viewModel.streak)
                .animation(.spring(), value: viewModel.streak)

            // Question category label
            Text(question.category)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())

            // Question text
            Text(question.question)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)

            // Answer buttons
            VStack(spacing: 10) {
                ForEach(question.shuffledAnswers, id: \.self) { answer in
                    AnswerButton(
                        answer: answer,
                        isCorrectAnswer: answer == question.correctAnswer,
                        selectedAnswer: viewModel.selectedAnswer
                    ) {
                        viewModel.submit(answer: answer)
                    }
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
    }
}

private struct GameScoreDisplay: View {
    @ObservedObject var viewModel: QuizRushViewModel
    @State private var scoreScale: CGFloat = 1.0

    var body: some View {
        HStack(alignment: .center, spacing: 0) {

            // Score
            VStack(alignment: .leading, spacing: 3) {
                Text("SCORE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(1.2)

                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.yellow)

                    Text("\(viewModel.score)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.6),
                            value: viewModel.score
                        )
                        .scaleEffect(scoreScale)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Question counter
            VStack(spacing: 3) {
                Text("QUESTION")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(1.2)

                Text("\(viewModel.currentIndex + 1) / \(viewModel.questions.count)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)

            // Timer
            VStack(spacing: 3) {
                Text("TIME")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(1.2)

                TimerRing(timeRemaining: viewModel.timeRemaining, total: 15.0)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
        // Score pop animation
        .onChange(of: viewModel.score) { _, _ in
            withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                scoreScale = 1.45
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring()) { scoreScale = 1.0 }
            }
        }
    }
}
