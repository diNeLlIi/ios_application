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
                            
                            StatsTab()
                                .tabItem { Label("Stats", systemImage: "chart.bar") }
                            
                            MapTab()
                                .tabItem { Label("Map", systemImage: "map") }
                            
                            SettingsTab()
                                .tabItem { Label("Settings", systemImage: "gear") }
                        }
                        .environmentObject(statViewModel)
                        .environmentObject(locationService)
                        .preferredColorScheme(.dark)
                    }
        
    }
}

