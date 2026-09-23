//
//  ContentView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = CaloriesViewModel()
    @State private var currentTab: ActiveTab = .rings

    var body: some View {
        NavigationStack {
            TabView(selection: $currentTab) {
                ForEach(ActiveTab.visibleTabs) { tab in
                    Tab(value: tab) {
                        NavigationStack {
                            tab.tabContent
                                .containerBackground(tab.tabColor.gradient, for: .tabView)
                                .toolbarForegroundStyle(tab.tabColor, for: .automatic)
                        }
                    }
                }
            }
            .tabViewStyle(.carousel)
            .task {
                await viewModel.getStatistics(for: .now)
                await viewModel.getTodayStatistics(for: .now)
            }
            .sheet(isPresented: $viewModel.addingData) {
                NewEntryView()
            }
            .environment(viewModel)
            .overlays()
        }
    }
}

#Preview {
    ContentView()
        .environments()
}
