//
//  ContentView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(CaloriesViewModel.self) private var viewModel
    @State private var currentTab: ActiveTab = .rings

    var body: some View {
        @Bindable var viewModel = self.viewModel
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
                WidgetCenter.shared.reloadTimelines(ofKind: "CaloriesRingsWidgets")
            }
            .overlays()
        }
    }
}

#Preview {
    ContentView()
        .environments()
}
