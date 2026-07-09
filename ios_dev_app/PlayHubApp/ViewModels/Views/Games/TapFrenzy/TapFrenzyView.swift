//
//  TapFrenzyView.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-08.
//

import SwiftUI
internal import Combine
import _LocationEssentials

struct TapFrenzyView: View {
    @StateObject private var vm = TapFrenzyVM()
    @EnvironmentObject var statViewModel: StatusGame
    @EnvironmentObject var locationService: LocationService
    
    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .receive(on: RunLoop.main)

    var body: some View {
        ZStack {
            // background image
            Image("background-wood-cartoon")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                //Tap Counter
                Text("Tap Counter")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 30)

               //tap count
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 220, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 3)
                        )

                    VStack(spacing: 4) {
                        Text("TAP COUNT")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                            .tracking(2)
                        Text("\(vm.tapCount)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 10)

                Spacer()

                // Tap button
                Button(action: vm.handleTap) {
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 4)
                            .frame(width: 200, height: 200)

                        Circle()
                            .fill(vm.isGameActive ? Color.orange.opacity(0.9) : Color.white.opacity(0.6))
                            .frame(width: 190, height: 190)

                        VStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 40))
                                .foregroundColor(vm.isGameActive ? .white : .gray)
                            Text("TAP")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(vm.isGameActive ? .white : .gray)
                        }
                    }
                }
                .scaleEffect(vm.circleScale)
                .disabled(!vm.isGameActive)
                .animation(.spring(response: 0.15, dampingFraction: 0.5), value: vm.circleScale)

                Spacer()

                //time remaining
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 220, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 3)
                        )

                    VStack(spacing: 4) {
                        Text("TIME REMAINING")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                            .tracking(2)
                        Text("\(vm.timeRemaining)s")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(
                                vm.timeRemaining <= 3 && vm.isGameActive ? .red : .black
                            )
                    }
                }
                .padding(.top, 10)

                // Start/Restart Button
                Button(action: vm.isGameOver ? vm.resetGame : vm.startGame) {
                    Text(vm.isGameOver ? "Play Again" : (vm.isGameActive ? "Running..." : "Start"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 160, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(vm.isGameActive ? Color.gray.opacity(0.6) : Color.brown)
                        )
                }
                .disabled(vm.isGameActive)
                .padding(.top, 20)
                .padding(.bottom, 50)
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
}

#Preview {
    TapFrenzyView()
}
