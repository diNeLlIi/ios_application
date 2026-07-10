//
//  StatsTab.swift
//  ios_dev_app
//

import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject var statViewModel: StatusGame
    @State private var selectedMode: GameMode = .tapFrenzy

    private var filteredSessions: [GameSession] {
        statViewModel.sessions
            .filter { $0.mode == selectedMode }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var chartSessions: [GameSession] {
        filteredSessions.sorted { $0.timestamp < $1.timestamp }
    }

    private func gamesPlayed(for mode: GameMode) -> Int {
        statViewModel.sessions.filter { $0.mode == mode }.count
    }

    private func bestScore(for mode: GameMode) -> Int {
        statViewModel.sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    private func averageScore(for mode: GameMode) -> Double {
        let scores = statViewModel.sessions.filter { $0.mode == mode }.map(\.score)
        guard !scores.isEmpty else { return 0 }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }

    private func peakDeltaPercent(for mode: GameMode) -> Int {
        let avg = averageScore(for: mode)
        guard avg > 0 else { return 0 }
        return Int(((Double(bestScore(for: mode)) - avg) / avg) * 100)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") { overviewSection }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                Section("Progress") { progressCard }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                Section("History") {
                    if filteredSessions.isEmpty {
                        Text("No \(selectedMode.rawValue) games yet.")
                            .foregroundColor(.gray)
                            .padding(.vertical)
                    } else {
                        ForEach(filteredSessions) { session in
                            historyRow(session)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats")
//            .toolbar {
//                if !statViewModel.sessions.isEmpty {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("Clear All", role: .destructive) {
//                            statViewModel.clearStats()
//                        }
//                    }
//                }
//            }
        }
    }

    
    private var overviewSection: some View {
        VStack(spacing: 10) {
            ForEach(GameMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut) { selectedMode = mode }
                } label: {
                    overviewCard(for: mode)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private func overviewCard(for mode: GameMode) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorForMode(mode).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconForMode(mode))
                    .foregroundColor(colorForMode(mode))
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(mode.rawValue)
                    .font(.system(size: 15, weight: .medium))
                Text("\(gamesPlayed(for: mode)) games played")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(bestScore(for: mode))")
                    .font(.system(size: 20, weight: .medium))
                Text("best")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(selectedMode == mode ? colorForMode(mode) : .clear, lineWidth: 2)
        )
    }

    
    //chart card

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            modePickerPills

            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(bestScore(for: selectedMode))")
                        .font(.system(size: 22, weight: .medium))
                    Text("peak score")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                let delta = peakDeltaPercent(for: selectedMode)
                if delta != 0 {
                    Text("\(delta > 0 ? "+" : "")\(delta)% vs avg")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colorForMode(selectedMode))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(colorForMode(selectedMode).opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if chartSessions.isEmpty {
                Text("No games played yet.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                Chart {
                    ForEach(Array(chartSessions.enumerated()), id: \.element.id) { index, session in
                        BarMark(
                            x: .value("Session", "G\(index + 1)"),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(
                            session.score == bestScore(for: selectedMode)
                                ? colorForMode(selectedMode)
                                : colorForMode(selectedMode).opacity(0.35)
                        )
                        .cornerRadius(6)
                    }
                }
                .frame(height: 140)
                .chartYAxis(.hidden)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
    }

    private var modePickerPills: some View {
        HStack(spacing: 4) {
            ForEach(GameMode.allCases, id: \.self) { mode in
                Text(mode.rawValue)
                    .font(.system(size: 13, weight: selectedMode == mode ? .medium : .regular))
                    .foregroundColor(selectedMode == mode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedMode == mode ? Color(.tertiarySystemGroupedBackground) : .clear)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut) { selectedMode = mode }
                    }
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGroupedBackground)))
    }
    
    
    private func historyRow(_ session: GameSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.timestamp, style: .date)
                    .font(.subheadline)
                Text(session.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(session.score)")
                .font(.title3.bold())
                .foregroundColor(colorForMode(session.mode))
        }
        .padding(.vertical, 4)
    }

    private func deleteSessions(at offsets: IndexSet) {
        offsets.map { filteredSessions[$0] }.forEach { statViewModel.deleteSession($0) }
    }

    private func iconForMode(_ mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "questionmark.diamond.fill"
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
