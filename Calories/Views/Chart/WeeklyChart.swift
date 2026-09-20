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
        Chart(data, id: \.self) { item in
            let sum = item.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            let isToday = Calendar.current.startOfDay(for: item.endDate) == Calendar.current.startOfDay(for: .now)
            BarMark(
                x: .value("Date", item.endDate, unit: .day),
                y: .value("Calories", sum)
            )
            .foregroundStyle(sum > viewModel.calorieLimit ? Color.red.gradient : isToday ? Color.green.gradient : Color.gray.gradient)
            .clipShape(.rect(cornerRadius: 8))
            .annotation(position: .top) {
                if sum > 0 {
                    Text(sum, format: .number.precision(.fractionLength(0)))
                        .font(.caption2)
                        .foregroundStyle(sum > viewModel.calorieLimit ? .red : .gray)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisGridLine(stroke: .init(lineWidth: 0.5, dash: [2, 2]))
                    .foregroundStyle(Color(.systemGray5))
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisGridLine()
                    .foregroundStyle(Color(.systemGray6))
                AxisValueLabel()
            }
        }
        .frame(height: 220)
    }
}
