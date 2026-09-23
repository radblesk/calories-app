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

    var maxValue: Double {
        let values = data.map { $0.extractedValue() }
        let sorted = values.sorted()
        return sorted.last ?? 0
    }

    var averageValue: Double {
        let values = data.map { $0.extractedValue() }
        let nonZeroValues = values.filter({ !$0.isZero })
        let average = nonZeroValues.reduce(0, +) / Double(nonZeroValues.count)
        return average
    }

    var body: some View {
        Chart(data, id: \.self) { item in
            BarMark(
                x: .value("Day", item.endDate, unit: .weekday),
                y: .value("Calories", item.extractedValue()),
                width: .ratio(0.5)
            )
            .foregroundStyle(
                item.extractedValue() > viewModel.calorieLimit
                    ? Color.pink.gradient : item.endDate.isToday ? Color.blue.gradient : Color.gray.gradient
            )
            .clipShape(.rect(cornerRadius: 4))
            .annotation(position: .top) {
                if item.extractedValue() > 0 {
                    Text(item.formattedValue())
                        .font(.caption2)
                        .foregroundStyle(item.extractedValue() > viewModel.calorieLimit ? .pink : item.endDate.isToday ? .blue : .gray)
                }
            }

            RuleMark(y: .value("Average", averageValue))
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundStyle(.gray.opacity(0.1))
                .annotation(position: .top, alignment: .leading) {
                    Text("Average")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if value.as(Date.self)!.isToday {
                    AxisGridLine()
                        .foregroundStyle(.blue)
                    AxisTick()
                        .foregroundStyle(.blue)
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                        .foregroundStyle(.blue)
                } else {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            }
        }
        .chartXScale(range: .plotDimension(startPadding: 100))
        .chartYAxis(.hidden)
        .frame(height: 220)
    }
}

#Preview {
    SummaryView()
        .environment(CaloriesViewModel())
        .overlays()
        .environments()
}
