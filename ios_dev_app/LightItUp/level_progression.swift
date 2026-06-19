//
//  level_progression.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-19.
//

import SwiftUI
internal import Combine

struct LitCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

enum GameLevel: Int, CaseIterable {
    case level1, level2, level3, level4
    
    var columnCount:Int{
        switch self {
        case .level1:
            return 1
        case .level2:
            return 2
        case .level3:
            return 2
        case .level4:
            return 3
        }
    }
    
    var totalCount: Int{
        switch self {
        case .level1:
            return 3
        case .level2:
            return 4
        case .level3:
            return 6
        case .level4:
            return 9
        }
    }

    var litCount: Int { self == .level4 ? 2 : 1 }

    var litTime: Double {
        switch self {
        case .level1:
            return 1.5
        case .level2:
            return 1.2
        case .level3:
            return 1.0
        case .level4:
            return 0.8
        }
    }

    var cardHeight: CGFloat {
        switch self {
        case .level1:
            return 140
        case .level2:
            return 120
        case .level3:
            return 100
        case .level4:
            return 80
        }
    }

    var glowColor: Color {
        switch self {
        case .level1:
            return .teal
        case .level2:
            return .blue
        case .level3:
            return .purple
        case .level4:
            return .green
        }
    }

    var levelName: String {
        switch self {
        case .level1: 
            return "Level 1"
        case .level2: 
            return "Level 2"
        case .level3: 
            return "Level 3"
        case .level4:
            return "Level 4"
        }
    }
}

struct LightItUpView: View {
    
}

#Preview {
    LightItUpView()
}
