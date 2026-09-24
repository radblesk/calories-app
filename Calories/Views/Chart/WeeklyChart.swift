//
//  WeeklyChart.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import Charts
internal import HealthKit
import SwiftUI

struct WeeklyChart: View {
    let data: [HKStatistics]

    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        Chart {
            ForEach(data, id: \.startDate) { item in
                BarMark(
                    x: .value("Day", item.startDate, unit: .weekday),
                    y: .value("Calories", item.extractedValue(in: viewModel.unit)),
                    width: .ratio(0.5)
                )
                .foregroundStyle(
                    item.extractedValue(in: viewModel.unit) > viewModel.calorieLimit
                        ? Color.orange.gradient : item.startDate.isToday ? Color.accent.gradient : Color.accent.opacity(0.2).gradient
                )
                .clipShape(.rect(cornerRadius: 4))
                .annotation(position: .top) {
                    if item.extractedValue(in: viewModel.unit) > 0 {
                        Text(item.formattedValue(in: viewModel.unit))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                item.extractedValue(in: viewModel.unit) > viewModel.calorieLimit ? .orange : item.startDate.isToday ? .accent : .gray
                            )
                    }
                }

            }

            RuleMark(y: .value("Average", viewModel.weeklyAverage))
                .lineStyle(StrokeStyle(lineWidth: 0.5, lineCap: .round, dash: [3, 3]))
                .foregroundStyle(.accent)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if value.as(Date.self)!.isToday {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                        .foregroundStyle(.accent)
                    AxisGridLine()
                        .foregroundStyle(.accent)
                    AxisTick()
                        .foregroundStyle(.accent)
                } else {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, lineCap: .round))
                        .foregroundStyle(Color.accent.gradient.tertiary)
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5, lineCap: .round))
                        .foregroundStyle(Color.accent.gradient.tertiary)
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: 220)
    }
}

#Preview {
    SummaryView()
        .overlays()
        .environments()
}
