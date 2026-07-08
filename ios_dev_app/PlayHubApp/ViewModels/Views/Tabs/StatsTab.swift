//
//  Untitled.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject var statsVM: StatusGame
    
    var body: some View {
        NavigationStack {
            List {
                Section("Performance Chart") {
                    if statsVM.sessions.isEmpty {
                        Text("Play some games to see your stats!")
                            .foregroundColor(.gray)
                    } else {
                        Chart(statsVM.sessions) { session in
                            BarMark(
                                x: .value("Mode", session.mode.rawValue),
                                y: .value("Score", session.score)
                            )
                            .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                        }
                        .frame(height: 250)
                        .padding(.vertical)
                    }
                }
                
                Section("Recent Sessions") {
                    ForEach(statsVM.sessions.reversed()) { session in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.mode.rawValue).font(.headline)
                                Text(session.timestamp, style: .date).font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(session.score)").bold()
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}
