//
//  TriviaService.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-30.
//

import Foundation

enum TriviaError: Error {
    case network
    case decoding
}

struct TriviaService {
    private let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    func fetchQuestions() async throws -> [Question] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TriviaError.network
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return decoded.results.map { raw in
                Question(
                    category: raw.category,
                    question: raw.question.htmlDecoded,
                    correctAnswer: raw.correctAnswer.htmlDecoded,
                    incorrectAnswers: raw.incorrectAnswers.map { $0.htmlDecoded }
                )
            }
        } catch {
            throw TriviaError.decoding
        }
    }
}
