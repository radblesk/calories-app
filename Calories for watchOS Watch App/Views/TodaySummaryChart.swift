//
//  TodaySummaryChart.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 23/09/2026.
//

import Charts
internal import HealthKit
import SwiftUI

struct TodaySummaryChart: View {
    let data: [HKStatistics]
    @Environment(CaloriesViewModel.self) private var viewModel

    var maxValue: Double { data.map { $0.extractedValue(in: viewModel.unit) }.max() ?? 0 }
    var minimumBarValue: Double { maxValue * 0.03 }

    var body: some View {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        VStack(alignment: .leading, spacing: 0) {
            Chart(data, id: \.startDate) { item in
                BarMark(
                    x: .value(
                        "Time",
                        item.startDate..<item.endDate
                    ),
                    y: .value("Calories", max(item.extractedValue(in: viewModel.unit), minimumBarValue))
                )
                .foregroundStyle(.cyan.gradient)
                .clipShape(.capsule)
            }
            .chartXScale(domain: startOfDay...endOfDay)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) {
                    AxisValueLabel(format: .dateTime.hour())
                    AxisGridLine()
                        .foregroundStyle(Color.cyan.gradient.quaternary)
                    AxisTick()
                        .foregroundStyle(Color.cyan.gradient.quaternary)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 80)
            .padding(.bottom, 20)

            ChartInfoItem(value: viewModel.caloriesConsumed, secondaryValue: viewModel.calorieLimit, tertiaryValue: viewModel.consumedProgress)
                .foregroundStyle(.cyan)
        }
        .padding(16)
        .padding(.bottom, -50)
    }
}
