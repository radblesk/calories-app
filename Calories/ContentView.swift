//
//  ContentView.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            SummaryView()
                .overlays()
                .task(id: scenePhase) {
                    await HealthStoreClient.shared.requestAuthorizationIfNeeded()

                    if scenePhase == .active {
                        await viewModel.getStatistics(for: .now)
                        await viewModel.getTodayStatistics(for: .now)
                    } else {
                        viewModel.cancelTasks()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .overlays()
        .environments()
}
