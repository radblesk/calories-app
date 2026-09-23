//
//  TodaySummaryTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 23/09/2026.
//

import SwiftUI

struct TodaySummaryTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel
    @AppStorage("dailyLimit") private var dailyLimit: Double = 1500

    var body: some View {
        TodaySummaryChart(data: viewModel.todayStatistics)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    NumberField("Daily Limit", value: $dailyLimit) {
                        Image(systemName: "plusminus.circle")
                    }
                }
            }
            .onChange(of: dailyLimit) { _, newValue in
                WatchSyncManager.shared.syncDailyLimit(newValue)
            }
    }
}

#Preview {
    TodaySummaryTabView()
        .environment(CaloriesViewModel())
}
