//
//  QuizRushViewModel.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-30.
//

import Foundation
import SwiftUI
import UIKit
internal import Combine

enum QuizState {
    case loading
    case loaded
    case failed
}

@MainActor
final class QuizRushViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .loading
    @Published var selectedAnswer: String?
    @Published var showResults = false
    
    // timer properties
    @Published var timeRemaining: Double = 15.0
    private let questionDuration: Double = 15.0
    private var timerTask: Task<Void, Never>?

    private let service = TriviaService()

    var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    
    func load() async {
        state = .loading
        do {
            questions = try await service.fetchQuestions()
            currentIndex = 0
            score = 0
            streak = 0
            showResults = false
            state = .loaded
            startTimer()
        } catch {
            state = .failed
        }
    }
    
    func submit(answer: String) {
        guard let question = currentQuestion, selectedAnswer == nil else { return }
        stopTimer()
        selectedAnswer = answer

        if answer == question.correctAnswer {
            streak += 1
            score += 10 + (streak >= 3 ? 5 : 0)
            triggerHaptic(correct: true)
        } else {
            streak = 0
            score = max(0, score - 2)
            triggerHaptic(correct: false)
        }

        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            advance()
        }
    }
    
    private func advance() {
        selectedAnswer = nil
        withAnimation(.easeInOut(duration: 0.35)) {
            if currentIndex < questions.count - 1 {
                currentIndex += 1
                startTimer()
            } else {
                showResults = true
            }
        }
    }
    
    //timer setting
    func startTimer() {
        timerTask?.cancel()
        timeRemaining = questionDuration

        timerTask = Task {
            while timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                if Task.isCancelled { return }
                timeRemaining = max(0, timeRemaining - 0.1)
            }
            if selectedAnswer == nil {
                timeExpired()
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func timeExpired() {
        guard selectedAnswer == nil else { return }
        streak = 0
        score = max(0, score - 2)
        selectedAnswer = "__timeout__"
        triggerHaptic(correct: false)

        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            advance()
        }
    }
    
    private func triggerHaptic(correct: Bool) {
        let generator = UIImpactFeedbackGenerator(style: correct ? .light : .heavy)
        generator.impactOccurred()
    }
}
