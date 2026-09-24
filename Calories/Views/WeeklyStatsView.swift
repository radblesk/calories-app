//
//  WeeklyStatsView.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

internal import HealthKit
import SwiftUI

struct WeeklyStatsView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 40) {
                ChartTopRowItem(title: "Total", value: viewModel.weeklyTotal)
                ChartTopRowItem(title: "Average", value: viewModel.weeklyAverage)
            }
            ChartRangeView {
                if let firstDate = viewModel.statistics.first?.endDate {
                    Text(firstDate.formatted(.dateTime.day().month()))
                }
                if let lastDate = viewModel.statistics.last?.endDate {
                    Text(lastDate.formatted(.dateTime.day().month()))
                }
                Text(Calendar.current.component(.year, from: .now).formatted(.number.grouping(.never)))
            }
        }
        WeeklyChart(data: viewModel.statistics)
    }
}

#Preview {
    WeeklyStatsView()
}
