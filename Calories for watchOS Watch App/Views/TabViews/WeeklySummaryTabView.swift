//
//  WeeklySummaryTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct WeeklySummaryTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        WeeklySummaryChart(data: viewModel.statistics)
            .navigationTitle("Weekly Summary")
    }
}

#Preview {
    WeeklySummaryTabView()
        .environment(CaloriesViewModel())
}
