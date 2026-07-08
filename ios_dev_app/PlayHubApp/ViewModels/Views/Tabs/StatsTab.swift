//
//  StatsTab.swift
//  ios_dev_app
//

import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject var statViewModel: StatusGame
    
    @State private var selectedMode: GameMode = .tapFrenzy
    
    var totalGames: Int {
        statViewModel.sessions.count
    }
    
    func bestScore(for mode: GameMode) -> Int {
        statViewModel.sessions
            .filter { $0.mode.rawValue == mode.rawValue }
            .map { $0.score }
            .max() ?? 0
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                   
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedMode = mode
                            }
                        }) {
                            HStack {
                                Text("Best: \(mode.rawValue)")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(bestScore(for: mode))")
                                    .font(.headline.bold())
                                    .foregroundColor(colorForMode(mode))
                                
                            }
                        }
                    }
                }
                
                Section("\(selectedMode.rawValue) Chart") {
                    let filteredSessions = statViewModel.sessions
                        .filter { $0.mode.rawValue == selectedMode.rawValue }
                        .sorted { $0.timestamp < $1.timestamp }
                    
                    if filteredSessions.isEmpty {
                        Text("No games played yet.")
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    } else {
                        Chart {
                            ForEach(Array(filteredSessions.enumerated()), id: \.element.id) { index, session in
                                BarMark(
                                    x: .value("Session", "G\(index + 1)"),
                                    y: .value("Score", session.score)
                                )
                                .foregroundStyle(colorForMode(selectedMode))
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 220)
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Recent Games") {
                    if statViewModel.sessions.isEmpty {
                        Text("No recent games.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(statViewModel.sessions.reversed()) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.mode.rawValue)
                                        .font(.headline)
                                        .foregroundColor(colorForMode(session.mode))
                                    Text(session.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("\(session.score)")
                                    .font(.title3.bold())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
    
    private func colorForMode(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .cyan
        case .lightItUp: return .teal
        case .quizRush: return .orange
        }
    }
}

#Preview {
    StatsTab().environmentObject(StatusGame())
}
