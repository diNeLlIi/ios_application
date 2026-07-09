import SwiftUI

@main
struct PlayHubApp: App {
    @StateObject private var statViewModel = StatusGame()
    @StateObject private var locationService = LocationService()
    init() {
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeTab()
                    .tabItem { Label("Play", systemImage: "gamecontroller") }
                    .toolbarBackground(Color(white: 0.08), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)

                StatsTab()
                    .tabItem { Label("Stats", systemImage: "chart.bar") }
                    .toolbarBackground(Color(white: 0.08), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)

                MapTab()
                    .tabItem { Label("Map", systemImage: "map") }
                    .toolbarBackground(Color(white: 0.08), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)

                SettingsTab()
                    .tabItem { Label("Settings", systemImage: "gear") }
                    .toolbarBackground(Color(white: 0.08), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
            }
            // Sets the selected tab icon and text color to white
            .tint(.white)
            .environmentObject(statViewModel)
            .environmentObject(locationService)
            .preferredColorScheme(.dark)
        }
    }
}
