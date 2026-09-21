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
            BarMark(
                x: .value("Date", item.endDate, unit: .day),
                y: .value("Calories", item.extractedValue())
            )
            .foregroundStyle(
                item.extractedValue() > viewModel.calorieLimit
                    ? Color.red.gradient : item.endDate.isToday ? Color.green.gradient : Color.gray.gradient
            )
            .clipShape(.rect(cornerRadius: 8))
            .annotation(position: .top) {
                if item.extractedValue() > 0 {
                    Text(item.formattedValue())
                        .font(.caption2)
                        .foregroundStyle(item.extractedValue() > viewModel.calorieLimit ? .red : .gray)
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
