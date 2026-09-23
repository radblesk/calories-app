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
    @AppStorage("unit") private var unit: Unit = .kcal

    var body: some View {
        Chart {
            ForEach(data, id: \.startDate) { item in
                BarMark(
                    x: .value("Day", item.startDate, unit: .weekday),
                    y: .value("Calories", item.extractedValue(in: unit)),
                    width: .ratio(0.5)
                )
                .foregroundStyle(
                    item.extractedValue(in: unit) > viewModel.calorieLimit
                        ? Color.orange.gradient : item.startDate.isToday ? Color.accent.gradient : Color.gray.gradient
                )
                .clipShape(.rect(cornerRadius: 4))
                .annotation(position: .top) {
                    if item.extractedValue(in: unit) > 0 {
                        Text(item.formattedValue(in: unit))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                item.extractedValue(in: unit) > viewModel.calorieLimit ? .orange : item.startDate.isToday ? .accent : .gray
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
