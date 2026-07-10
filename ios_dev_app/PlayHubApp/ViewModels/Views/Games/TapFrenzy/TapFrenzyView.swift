//
//  TapFrenzyView.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine
import CoreLocation

struct TapFrenzyView: View {
    @StateObject private var vm = TapFrenzyVM()
    @EnvironmentObject var statViewModel: StatusGame
    @EnvironmentObject var locationService: LocationService

    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .receive(on: RunLoop.main)

    var body: some View {
        ZStack {
            Image("background-wood-cartoon")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.15)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                playArea
            }
        }
        .onReceive(timer) { _ in
            if Thread.isMainThread {
                vm.timerTick()
            } else {
                DispatchQueue.main.async {
                    vm.timerTick()
                }
            }
        }
        .onChange(of: vm.isGameOver) { _, isOver in
            guard isOver else { return }
            let coord = locationService.currentLocation
            statViewModel.saveSession(
                mode: .tapFrenzy,
                score: vm.tapCount,
                lat: coord?.latitude ?? 0,
                lng: coord?.longitude ?? 0
            )
        }
        .alert("Game Over!", isPresented: $vm.showAlert) {
            Button("OK") {
                vm.resetGame()
            }
        } message: {
            Text("You tapped \(vm.tapCount) time\(vm.tapCount == 1 ? "" : "s") in \(vm.timeLimit) seconds!")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            statPill(label: "TAPS", value: "\(vm.tapCount)")
            statPill(
                label: "TIME",
                value: "\(vm.timeRemaining)s",
                valueColor: vm.timeRemaining <= 3 && vm.isGameActive ? .red : .black
            )
        }
        .padding(.top, 100)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private func statPill(label: String, value: String, valueColor: Color = .black) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.brown)
                .tracking(1.5)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                )
        )
    }

    
    private var playArea: some View {
        GeometryReader { geo in
            ZStack {
                if !vm.isGameActive && !vm.isGameOver {
                    Text("Tap to start!")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .position(x: geo.size.width / 2, y: 30)
                        .transition(.opacity)
                }

                tapButton
                    .position(vm.buttonPosition)
            }
            .onAppear {
                vm.updateContainerSize(geo.size)
            }
            .onChange(of: geo.size) { _, newSize in
                vm.updateContainerSize(newSize)
            }
        }
        .padding(.bottom, 100)
    }

    private var tapButton: some View {
        Button(action: vm.handleTap) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange, Color.orange.opacity(0.75)],
                            center: .center,
                            startRadius: 2,
                            endRadius: vm.buttonSize / 2
                        )
                    )
                    .overlay(Circle().stroke(Color.black, lineWidth: 4))
                    .shadow(color: .black.opacity(0.35), radius: 8, y: 4)

                VStack(spacing: vm.buttonSize > 90 ? 6 : 0) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: min(vm.buttonSize * 0.32, 40)))
                        .foregroundColor(.white)

                    if vm.buttonSize > 90 {
                        Text("TAP")
                            .font(.system(size: min(vm.buttonSize * 0.14, 20), weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: vm.buttonSize, height: vm.buttonSize)
        }
        .buttonStyle(.plain)
        .scaleEffect(vm.circleScale)
        .animation(.spring(response: 0.15, dampingFraction: 0.5), value: vm.circleScale)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: vm.buttonPosition)
        .animation(.easeOut(duration: 0.15), value: vm.buttonSize)
    }
}

#Preview {
    TapFrenzyView()
}
