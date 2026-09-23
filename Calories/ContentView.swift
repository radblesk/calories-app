//
//  ContentView.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Summary", systemImage: "heart") {
                SummaryView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultTabBarPlacement(.sidebar)
        .overlays()
    }
}

#Preview {
    ContentView()
        .overlays()
        .environments()
}
