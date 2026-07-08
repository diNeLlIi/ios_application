//
//  TriviaModels.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-30.
//

import Foundation

struct TriviaResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    let id = UUID()
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let shuffledAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    init(category: String, question: String, correctAnswer: String, incorrectAnswers: [String]) {
        self.category = category
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
        self.shuffledAnswers = (incorrectAnswers + [correctAnswer]).shuffled()
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        category = try c.decode(String.self, forKey: .category)
        question = try c.decode(String.self, forKey: .question)
        correctAnswer = try c.decode(String.self, forKey: .correctAnswer)
        incorrectAnswers = try c.decode([String].self, forKey: .incorrectAnswers)
        shuffledAnswers = (incorrectAnswers + [correctAnswer]).shuffled()
    }
}
