//
//  ResultsView.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
import _LocationEssentials

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let action: () -> Void 
    
    @EnvironmentObject var statsVM: StatusGame
    @EnvironmentObject var locationService: LocationService
    @State private var hasSaved = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle.bold())
            
            Text("You scored \(score) in \(mode.rawValue)")
                .font(.title2)
            
            // ShareLink requirement
            ShareLink(item: "I just scored \(score) on \(mode.rawValue) in PlayHub — beat that!") {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button("Play Again", action: action)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(width: 200)
                .background(Color.white)
                .cornerRadius(10)
        }
        .padding()
        .onAppear {
            if !hasSaved {
                
                //saving the session details using  current location
                let lat = locationService.currentLocation?.latitude ?? 0.0
                let lng = locationService.currentLocation?.longitude ?? 0.0
                statsVM.saveSession(mode: mode, score: score, lat: lat, lng: lng)
                hasSaved = true
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
}
