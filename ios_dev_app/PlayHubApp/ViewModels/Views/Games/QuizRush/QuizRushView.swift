//
//  QuizRushView.swift
//  ios_dev_app
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()

    var body: some View {
        ZStack {
            QuizBackground(
                streak: viewModel.streak,
                timeRemaining: viewModel.timeRemaining
            )
            .ignoresSafeArea()

            switch viewModel.state {

            case .setup:
                QuizSetupView(viewModel: viewModel)

            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.3)
                    Text("Loading \(viewModel.selectedDifficulty.displayName) · \(viewModel.selectedCategory.name)…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                
            case .failed:
                VStack(spacing: 20) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                    Text(viewModel.errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Button("Try Again") {
                        Task { await viewModel.load() }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Back to Setup") {
                        viewModel.backToSetup()
                    }
                    .foregroundColor(.secondary)
                }
                .padding()

                
            case .noResults:
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary)
                    Text(viewModel.errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Button("Change Settings") {
                        viewModel.backToSetup()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

            case .loaded:
                if viewModel.showResults {
                    QuizResultsView(
                        score: viewModel.score,
                        difficulty: viewModel.selectedDifficulty,
                        category: viewModel.selectedCategory
                    ) {
                        viewModel.backToSetup()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                } else if let question = viewModel.currentQuestion {
                    QuizQuestionView(question: question, viewModel: viewModel)
                        .id(viewModel.currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
        }
    }
}

struct QuizBackground: View {
    let streak: Int
    let timeRemaining: Double

    var body: some View {
        LinearGradient(colors: [topColor, bottomColor], startPoint: .top, endPoint: .bottom)
            .animation(.easeInOut(duration: 0.6), value: streak)
            .animation(.easeInOut(duration: 0.3), value: timeRemaining < 5)
    }

    private var topColor: Color {
        if timeRemaining < 5 { return .red.opacity(0.3) }
        if streak >= 3       { return .orange.opacity(0.2) }
        return Color(.systemBackground)
    }

    private var bottomColor: Color {
        if timeRemaining < 5 { return Color(.systemBackground) }
        if streak >= 3       { return .yellow.opacity(0.1) }
        return Color(.secondarySystemBackground)
    }
}
