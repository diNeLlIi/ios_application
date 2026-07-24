//
//  TapFrenzy.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine

class TapFrenzyVM: ObservableObject {
    
    @Published var tapCount: Int = 0
    @Published var timeRemaining: Int = 10
    @Published var isGameActive: Bool = false
    @Published var isGameOver: Bool = false
    @Published var circleScale: CGFloat = 1.0
    @Published var showAlert: Bool = false
    @Published var buttonSize: CGFloat = TapFrenzyVM.maxButtonSize
    @Published var buttonPosition: CGPoint = .zero

    let timeLimit: Int = 10

    static let maxButtonSize: CGFloat = 180
    static let minButtonSize: CGFloat = 64
    private static let shrinkStep: CGFloat = 6

    private var containerSize: CGSize = .zero

    func updateContainerSize(_ size: CGSize) {
        containerSize = size
        if buttonPosition == .zero {
            centerButton()
        }
    }


    //game starts upon first tap
    func handleTap() {
        if !isGameActive && !isGameOver {
            isGameActive = true
            timeRemaining = timeLimit
            tapCount = 0
            buttonSize = Self.maxButtonSize
        }
        guard isGameActive else { return }

        tapCount += 1
        buttonSize = max(Self.minButtonSize, Self.maxButtonSize - CGFloat(tapCount) * Self.shrinkStep)

        circleScale = 0.88
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.circleScale = 1.0
        }

        randomizeButtonPosition()
    }

    func resetGame() {
        isGameActive = false
        isGameOver = false
        tapCount = 0
        timeRemaining = timeLimit
        showAlert = false
        circleScale = 1.0
        buttonSize = Self.maxButtonSize
        centerButton()
    }

    func timerTick() {
        guard isGameActive else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            isGameActive = false
            isGameOver = true
            showAlert = true
        }
    }

    private func centerButton() {
        guard containerSize != .zero else { return }
        buttonPosition = CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
    }


    private func randomizeButtonPosition() {
        
        guard containerSize.width > buttonSize, containerSize.height > buttonSize else { return }
        let half = buttonSize / 2
        let x = CGFloat.random(in: half...(containerSize.width - half))
        let y = CGFloat.random(in: half...(containerSize.height - half))
        buttonPosition = CGPoint(x: x, y: y)
        
    }
}
