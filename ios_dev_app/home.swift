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
                
                
            }
            
            
            
            
        }
        
    }
}

#Preview {
    Home()
}

