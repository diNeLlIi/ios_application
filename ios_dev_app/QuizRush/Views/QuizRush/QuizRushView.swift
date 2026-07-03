import SwiftUI

struct QuizBackground: View {
    let streak: Int
    let timeRemaining: Double

    private var topColor: Color {
        if timeRemaining < 5 { return Color.red.opacity(0.3) }
        if streak >= 3 { return Color.orange.opacity(0.2) }
        return Color(.systemBackground)
    }

    private var bottomColor: Color {
        if timeRemaining < 5 { return Color(.systemBackground) }
        if streak >= 3 { return Color.yellow.opacity(0.1) }
        return Color(.secondarySystemBackground)
    }

    var body: some View {
        LinearGradient(colors: [topColor, bottomColor], startPoint: .top, endPoint: .bottom)
            .animation(.easeInOut(duration: 0.6), value: streak)
            .animation(.easeInOut(duration: 0.3), value: timeRemaining < 5)
    }
}

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()

    var body: some View {
        ZStack {
            QuizBackground(streak: viewModel.streak, timeRemaining: viewModel.timeRemaining)
                .ignoresSafeArea()

            VStack {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading questions…")

                case .failed:
                    VStack(spacing: 16) {
                        Text("Couldn't load trivia. Check your connection.")
                        Button("Retry") {
                            Task { await viewModel.load() }
                        }
                    }

                case .loaded:
                    if viewModel.showResults {
                        QuizResultsView(score: viewModel.score) {
                            Task { await viewModel.load() }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if let question = viewModel.currentQuestion {
                        QuizQuestionView(question: question, viewModel: viewModel)
                            .id(viewModel.currentIndex)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
