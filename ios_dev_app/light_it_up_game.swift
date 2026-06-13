//
//  light_it_up_game.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-15.
//

import SwiftUI
internal import Combine

struct Light: View {
    var body: some View {
        ZStack{
            
            RadialGradient(colors: [.blue,.black], center: .center, startRadius: 10, endRadius: 200)
                .ignoresSafeArea()
            
            Text("Light It Up!")
                .font(Font.largeTitle.bold())
                .foregroundColor(.white)
        }
    }
}

#Preview {
    Light()
}
