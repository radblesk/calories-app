//
//  WeeklySummaryChart.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import Charts
internal import HealthKit
import SwiftUI

struct WeeklySummaryChart: View {
    let data: [HKStatistics]

    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Chart {
                ForEach(data, id: \.startDate) { item in
                    BarMark(
                        x: .value("Date", item.startDate, unit: .day),
                        y: .value("Calories", item.extractedValue(in: viewModel.unit)),
                        width: .ratio(0.5)
                    )
                    .foregroundStyle(
                        item.extractedValue(in: viewModel.unit) > viewModel.calorieLimit
                            ? Color.red.gradient : Color.green.gradient
                    )
                    .opacity(item.startDate.isToday ? 1 : 0.3)
                    .clipShape(.capsule)
                }

                RuleMark(y: .value("Average", viewModel.weeklyAverage))
                    .lineStyle(StrokeStyle(lineWidth: 0.5, lineCap: .round, dash: [3, 3]))
                    .foregroundStyle(.green)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if value.as(Date.self)!.isToday {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                            .foregroundStyle(.green)
                    } else {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                    }
                    AxisGridLine()
                        .foregroundStyle(Color.green.gradient.quaternary)
                    AxisTick()
                        .foregroundStyle(Color.green.gradient.quaternary)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 80)
            .padding(.bottom, 20)

            ChartInfoItem(
                value: viewModel.weeklyTotal,
                secondaryValue: viewModel.weeklyAverage,
                tertiaryValue: (viewModel.weeklyAverage / viewModel.calorieLimit)
            )
            .foregroundStyle(.green)
        }
        .padding(16)
        .padding(.bottom, -20)
    }
}

#Preview {
    @Previewable @State var viewModel = CaloriesViewModel.shared

    VStack {
        WeeklySummaryChart(data: viewModel.statistics)
            .environment(viewModel)
            .task {
                await viewModel.getStatistics(for: .now)
            }
    }
}
