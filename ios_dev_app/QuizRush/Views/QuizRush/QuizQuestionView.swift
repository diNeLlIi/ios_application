import SwiftUI

struct QuizQuestionView: View {
    let question: Question
    @ObservedObject var viewModel: QuizRushViewModel
    
    @State private var scoreScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                TimerRing(timeRemaining: viewModel.timeRemaining, total: 15.0)
            }
            .padding(.horizontal)

            StreakBadge(streak: viewModel.streak)
                .animation(.spring(), value: viewModel.streak)

            Text(question.question)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ForEach(question.shuffledAnswers, id: \.self) { answer in
                AnswerButton(
                    answer: answer,
                    isCorrectAnswer: answer == question.correctAnswer,
                    selectedAnswer: viewModel.selectedAnswer
                ) {
                    viewModel.submit(answer: answer)
                }
            }

            Text("Score: \(viewModel.score)")
                .font(.headline)
                .scaleEffect(scoreScale)
                .contentTransition(.numericText())
                .onChange(of: viewModel.score) { _, newValue in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                        scoreScale = 1.3
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring()) { scoreScale = 1.0 }
                    }
                }
                .padding(.top)
        }
        .padding()
    }
}
