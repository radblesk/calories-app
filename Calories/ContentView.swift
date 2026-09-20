//
//  ContentView.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

struct ContentView: View {

    @State private var count: Double = 0

    var body: some View {
        TabView {
            Tab("Summary", systemImage: "heart") {
                SummaryView()
            }
            Tab("Settings", systemImage: "gear") {
                Text("Settings View")
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultTabBarPlacement(.sidebar)
    }
}

#Preview {
    ContentView()
        .overlays()
        .environments()
}
