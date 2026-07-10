//
//  MapTab.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
import MapKit
import CoreLocation

private struct LocationPin: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let sessions: [GameSession]
    
    var totalCount: Int { sessions.count }
    
    var sessionsByMode: [GameMode: [GameSession]] {
        Dictionary(grouping: sessions, by: \.mode)
    }
    
    var lastPlayed: GameSession? {
        sessions.max { $0.timestamp < $1.timestamp }
    }
    
    var history: [GameSession] {
        sessions.sorted { $0.timestamp > $1.timestamp }
    }
    
    var dominantMode: GameMode {
        sessionsByMode.max { $0.value.count < $1.value.count }?.key ?? sessions[0].mode
    }
}

private func groupedPins(from sessions: [GameSession]) -> [LocationPin] {
    let precision = 1000.0
    let grouped = Dictionary(grouping: sessions) { session -> String in
        let roundedLat = (session.latitude * precision).rounded() / precision
        let roundedLng = (session.longitude * precision).rounded() / precision
        return "\(roundedLat),\(roundedLng)"
    }
    return grouped.map { key, sessions in
        LocationPin(id: key, coordinate: sessions[0].coordinate, sessions: sessions)
    }
}


private func modeTint(_ mode: GameMode) -> Color {
    switch mode {
    case .tapFrenzy: return .blue
    case .lightItUp: return .teal
    case .quizRush:  return .orange
    }
}

private func modeIcon(_ mode: GameMode) -> String {
    switch mode {
        
    case .tapFrenzy: return "hand.tap.fill"
        
    case .lightItUp: return "bolt.fill"
        
    case .quizRush:  return "brain.head.profile"
    }
}

struct MapTab: View {
    @EnvironmentObject var statsVM: StatusGame
    @EnvironmentObject var locationService: LocationService
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedPinID: String?
    @State private var hasCenteredOnUser = false
    
    private var locationPins: [LocationPin] {
        
        groupedPins(from: statsVM.sessions)
        
    }
    
    private var selectedPin: LocationPin? {
        let id = selectedPinID
        return locationPins.first { $0.id == id }
    }
    
    
    var body: some View {
        NavigationStack {
            
            Map(position: $cameraPosition, selection: $selectedPinID) {
                
                ForEach(locationPins) { pin in
                    let count = pin.totalCount
                    let label = "\(count) game\(count == 1 ? "" : "s")"
                    Marker(
                        label,
                        monogram: Text("\(count)").fontDesign(.rounded).bold(),
                        coordinate: pin.coordinate
                    )
                    .tint(modeTint(pin.dominantMode))
                    .tag(pin.id)
                }
                
            }
            
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .navigationTitle("Play Map")
            .overlay {
                if statsVM.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Games Yet",
                        systemImage: "map",
                        description: Text("Finish a game to drop your first pin.")
                    )
                }
            }
            .sheet(item: Binding(
                get: { selectedPin },
                set: { newValue in selectedPinID = newValue?.id }
            )) { pin in
                LocationDetailSheet(pin: pin)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear { centerCamera() }
            .onReceive(locationService.$currentLocation) { _ in
                centerCamera()
            }
        }
    }
    
    private func centerCamera() {
        guard !hasCenteredOnUser else { return }
        
        if let coord = locationService.currentLocation {
            hasCenteredOnUser = true
            cameraPosition = regionCamera(center: coord)
        } else if let firstPin = locationPins.first {
            cameraPosition = regionCamera(center: firstPin.coordinate)
        }
    }
    
    private func regionCamera(center: CLLocationCoordinate2D) -> MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    }
    
}

private struct LocationDetailSheet: View {
    let pin: LocationPin
    @State private var selectedMode: GameMode?
    
    private var modesPresent: [GameMode] {
        GameMode.allCases.filter { pin.sessionsByMode[$0] != nil }
    }
    
    private var filteredHistory: [GameSession] {
        guard let selectedMode else { return pin.history }
        return pin.history.filter { $0.mode == selectedMode }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            modeFilter
            statChips
            Divider()
            historyList
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(pin.totalCount) game\(pin.totalCount == 1 ? "" : "s") played here")
                .font(.title3.bold())
            
            if let last = pin.lastPlayed {
                HStack(spacing: 6) {
                    Circle()
                        .fill(modeTint(last.mode))
                        .frame(width: 8, height: 8)
                    Text("Last: \(last.mode.rawValue) · \(last.score) · \(last.timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 12)
    }
    
    private var modeFilter: some View {
        Picker("Mode", selection: $selectedMode) {
            Text("All").tag(GameMode?.none)
            ForEach(modesPresent, id: \.self) { mode in
                Text(mode.rawValue).tag(GameMode?.some(mode))
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var statChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(modesPresent, id: \.self) { mode in
                    let sessions = pin.sessionsByMode[mode] ?? []
                    let best = sessions.map(\.score).max() ?? 0
                    let isActive = selectedMode == mode
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMode = isActive ? nil : mode
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: modeIcon(mode))
                                Text(mode.rawValue)
                            }
                            .font(.caption.bold())
                            
                            Text("Best \(best) · \(sessions.count)×")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(modeTint(mode).opacity(isActive ? 0.28 : 0.14))
                        .foregroundColor(modeTint(mode))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
    }
    
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredHistory.isEmpty {
                    Text("No games in this mode at this location.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(Array(filteredHistory.enumerated()), id: \.element.id) { index, session in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(modeTint(session.mode).opacity(0.15))
                                Image(systemName: modeIcon(session.mode))
                                    .font(.caption)
                                    .foregroundColor(modeTint(session.mode))
                            }
                            .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.mode.rawValue)
                                    .font(.subheadline.bold())
                                Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(session.score)")
                                .font(.title3.bold())
                                .fontDesign(.rounded)
                                .foregroundColor(modeTint(session.mode))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        if index < filteredHistory.count - 1 {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
            }
        }
    }
}

