//
//  StatisticsTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct StatisticsTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel
    @AppStorage("dailyLimit") private var dailyLimit: Double = 1500

    var body: some View {
        VStack(alignment: .leading) {
            StatisticsRowView(title: "Consumed", value: viewModel.caloriesConsumed)
            Divider()
            StatisticsRowView(title: "Remaining", value: viewModel.caloriesRemaining)
            if let overLimit = viewModel.overLimit {
                Divider()
                StatisticsRowView(title: "Over Limit", value: overLimit)
            }
        }
        .padding(.horizontal)
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
    StatisticsTabView()
        .environments()
}
