//
//  home.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-15.
//

import SwiftUI
internal import Combine

struct Home: View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Strike")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                //font effects
                    .shadow(color: .teal, radius: 10)
                    .shadow(color: .blue, radius: 20)
                    .padding(.top, 40)
                
                
                Spacer()
                
                HStack{
                    Button(action: {
                        print("Light It Up game selected")
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                            
                            Text("Light It Up")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: 150, height: 160)
                        .background(Color.secondary.opacity(0.75)) // Dark card background
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.6), lineWidth: 2) // Neon border
                        )
                        .shadow(color: .yellow.opacity(0.3), radius: 10)
                    }
                }
            }
            
            
            
            
        }
        
    }
}

#Preview {
    Home()
}

