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

    enum CodingKeys: String, CodingKey {
        case category, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
