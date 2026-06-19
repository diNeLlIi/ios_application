//
//  light_it_up_game.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-15.
//

import SwiftUI
internal import Combine

struct Light: View {
    @State private var isAnimating = false
    @State private var navigateToNext = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.black.ignoresSafeArea()
//                let darkNavyBlue = Color(red: 0.0, green: 0.1, blue: 0.4)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue,.black],
                                       center: .center,
                                       startRadius: 10,
                                       endRadius: 200
                        )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.1)
                    .offset(y: isAnimating ? 0 : 500)
                
                Text("Light It Up!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                //                    .opacity(isAnimating ? 1.0 : 0.0)

            }
            // tap gesture to navigate on click
            .onTapGesture {
                navigateToNext = true
            }
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    isAnimating = true
                }
            }
            .navigationDestination(isPresented: $navigateToNext) {
                LightItUpView()
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            navigateToNext = true
                        }
                    }
            )
        }
    }
}


#Preview {
    Light()
}
