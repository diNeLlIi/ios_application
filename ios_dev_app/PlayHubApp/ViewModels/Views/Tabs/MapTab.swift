//
//  MapTab.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var statsVM: StatusGame
    
    var body: some View {
        NavigationStack {
            Map {
                ForEach(statsVM.sessions) { session in
                    let coord = CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)
                    Annotation(session.mode.rawValue, coordinate: coord) {
                        VStack {
                            Text("\(session.score)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            Image(systemName: "triangle.fill")
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(180))
                                .offset(y: -5)
                        }
                    }
                }
            }
            .navigationTitle("Play Map")
        }
    }
}
