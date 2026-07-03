//
//  home.swift
//  ios_dev_app
//
//  Created by student2 on 2026-06-15.
//

import SwiftUI
internal import Combine

struct Home: View {
    @AppStorage("lightItUpHighestScore") private var lightItUpBest = 0
    @AppStorage("tapFrenzyHighScore")    private var tapFrenzyBest  = 0
    @AppStorage("quizRushHighScore")     private var quizRushBest   = 0 

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Title
                    Text("Strike")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .teal, radius: 10)
                        .shadow(color: .blue, radius: 20)
                        .padding(.top, 60)

                    Text("CHOOSE YOUR MODE")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.35))
                        .padding(.top, 8)

                    Spacer()

                    // Game mode buttons
                    VStack(spacing: 16) {
                        //tap game
                        NavigationLink(destination: ContentView()) {
                            ModeCard(
                                title: "Tap Frenzy",
                                subtitle: "Tap as many cards as you can in 60 s",
                                accentColor: .cyan,
                                best: tapFrenzyBest
                            )
                        }
                        .buttonStyle(.plain)

                        //light tile game
                        NavigationLink(destination: Light()) {
                            ModeCard(
                                title: "Light It Up",
                                subtitle: "Tap the lit card before it goes dark",
                                accentColor: .teal,
                                best: lightItUpBest
                            )
                        }
                        .buttonStyle(.plain)
                        
                        //quiz rush
//                        NavigationLink(destination: QuizRushView()) {
//                            ModeCard(
//                                title: "Quiz Rush",
//                                subtitle: "Test your trivia knowledge against the clock",
//                                accentColor: .orange,
//                                best: quizRushBest
//                            )
//                        }
//                        .buttonStyle(.plain)
//                    }
//                    .padding(.horizontal, 24)
//
//                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ModeCard: View {
    let title:       String
    let subtitle:    String
    let accentColor: Color
    let best:        Int

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("BEST")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundColor(accentColor)
                Text("\(best)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
                )
        )
        .shadow(color: accentColor.opacity(0.25), radius: 12)
    }
}



#Preview { Home() }
