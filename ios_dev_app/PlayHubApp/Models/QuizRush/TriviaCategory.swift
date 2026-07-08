//
//  TriviaCategory.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import Foundation

struct TriviaCategory: Identifiable, Hashable {
    // id matches the trivia DB categegory IDs
    let id: Int
    let name: String
    let icon: String

    static let all = TriviaCategory(id: 0, name: "Any Category", icon: "square.grid.2x2.fill")

    static let categories: [TriviaCategory] = [
        TriviaCategory(id: 0,  name: "Any Category",      icon: "square.grid.2x2.fill"),
        TriviaCategory(id: 9,  name: "General Knowledge", icon: "brain.head.profile"),
        TriviaCategory(id: 11, name: "Film",              icon: "film.fill"),
        TriviaCategory(id: 12, name: "Music",             icon: "music.note"),
        TriviaCategory(id: 15, name: "Video Games",       icon: "gamecontroller.fill"),
        TriviaCategory(id: 17, name: "Science & Nature",  icon: "leaf.fill"),
        TriviaCategory(id: 18, name: "Computers",         icon: "laptopcomputer"),
        TriviaCategory(id: 21, name: "Sports",            icon: "sportscourt.fill"),
        TriviaCategory(id: 22, name: "Geography",         icon: "globe.americas.fill"),
        TriviaCategory(id: 23, name: "History",           icon: "building.columns.fill"),
        TriviaCategory(id: 27, name: "Animals",           icon: "pawprint.fill"),
    ]
}
