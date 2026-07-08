//
//  QuizSetupView.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI

struct QuizSetupView: View {
    @ObservedObject var viewModel: QuizRushViewModel

    @State private var currentStep = 0

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {

            // progress indicator
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { i in
                    Capsule()
                        .fill(i == currentStep ? Color.purple : Color.gray.opacity(0.35))
                        .frame(width: i == currentStep ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 4)

            // Step content
            if currentStep == 0 {
                categoryStep
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                difficultyStep
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
    }

    //category selection

    private var categoryStep: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            VStack(alignment: .leading, spacing: 6) {
                
                Text("Quiz Rush")
                    .font(.largeTitle.bold())
                
                
                Text("What do you want to be quizzed on?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 16)

            // Scrollable category grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(TriviaCategory.categories) { category in
                        
                        CategoryCard(
                            category: category,
                            isSelected: viewModel.selectedCategory.id == category.id
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            // Next button
            Button {
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentStep = 1
                }
                
            } label: {
                
                HStack(spacing: 8) {
                    Text("Next")
                    Image(systemName: "arrow.right")
                }
                
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }
    
    
    //game difficulty seletion
    private var difficultyStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {


                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("How hard?")
                        .font(.largeTitle.bold())
                    Text("Your score multiplier changes with difficulty")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Difficulty cards
                VStack(spacing: 12) {
                    ForEach(QuizDifficulty.allCases) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: viewModel.selectedDifficulty == difficulty
                        ) {
                            viewModel.selectedDifficulty = difficulty
                        }
                    }
                }
                .padding(.horizontal)

                // Scoring preview
                ScoringPreview(difficulty: viewModel.selectedDifficulty)
                    .padding(.horizontal)

                // Start Game button
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedDifficulty.color)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top, 12)
        }
    }
}

//category
private struct CategoryCard: View {
    let category: TriviaCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.purple : Color(.tertiarySystemBackground))
                        .frame(width: 48, height: 48)
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                Text(category.name)
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .purple : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.purple.opacity(0.12) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}


//difficulty level
private struct DifficultyCard: View {
    let difficulty: QuizDifficulty
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon in coloured circle
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(isSelected ? 1.0 : 0.18))
                        .frame(width: 50, height: 50)
                    Image(systemName: difficulty.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : difficulty.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("+\(difficulty.pointsPerCorrect) correct  ·  -\(difficulty.penalty) wrong  ·  +\(difficulty.streakBonus) streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Checkmark when selected
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? difficulty.color : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(isSelected ? difficulty.color.opacity(0.12) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? difficulty.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

private struct ScoringPreview: View {
    let difficulty: QuizDifficulty

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SCORING BREAKDOWN")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                ScoreChip(label: "Correct",   value: "+\(difficulty.pointsPerCorrect)", color: .green)
                ScoreChip(label: "Streak ×3", value: "+\(difficulty.streakBonus)",      color: .orange)
                ScoreChip(label: "Wrong",     value: "-\(difficulty.penalty)",          color: .red)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut, value: difficulty.rawValue)
    }
}

private struct ScoreChip: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(color)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: value)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
