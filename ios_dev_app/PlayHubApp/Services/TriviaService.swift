//
//  TriviaService.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-30.
//

import Foundation

enum TriviaError: Error, LocalizedError {
    case network
    case decoding
    case noResults
    case rateLimited 

    var errorDescription: String? {
        switch self {
        case .network:     return "Couldn't reach the server. Check your connection."
        case .decoding:    return "Something went wrong reading the questions."
        case .noResults:   return "No questions found for this combination"
        case .rateLimited: return "Too many requests. Try again in a moment."
        }
    }
}

struct TriviaService {
    func fetchQuestions(
        category: TriviaCategory,
        difficulty: QuizDifficulty
    ) async throws -> [Question] {
        
        //Trivia URL is created dynamically based on the users preferences
        
        var components = URLComponents(string: "https://opentdb.com/api.php")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "amount",     value: "10"),
            URLQueryItem(name: "type",       value: "multiple"),
            URLQueryItem(name: "difficulty", value: difficulty.rawValue)
        ]

        if category.id != 0 {
            queryItems.append(URLQueryItem(name: "category", value: "\(category.id)"))
        }

        components.queryItems = queryItems

        guard let url = components.url else { throw TriviaError.network }

    
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TriviaError.network
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)

            switch decoded.responseCode {
            case 0:  break
            case 1:  throw TriviaError.noResults
            case 5:  throw TriviaError.rateLimited
            default: throw TriviaError.network
            }

            return decoded.results.map { raw in
                Question(
                    category: raw.category,
                    question: raw.question.htmlDecoded,
                    correctAnswer: raw.correctAnswer.htmlDecoded,
                    incorrectAnswers: raw.incorrectAnswers.map { $0.htmlDecoded }
                )
            }
        } catch let error as TriviaError {
            throw error
        } catch {
            throw TriviaError.decoding
        }
    }
}

