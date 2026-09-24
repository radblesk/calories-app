//
//  TodaySummaryTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 23/09/2026.
//

import SwiftUI

struct TodaySummaryTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        TodaySummaryChart(data: viewModel.todayStatistics)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("Change Limit", systemImage: "plusminus.circle") {
                        viewModel.changingLimit.toggle()
                    }
                }
            }
    }
}

#Preview {
    TodaySummaryTabView()
        .environments()
}
