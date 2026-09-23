//
//  ChartBottomRow.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct ChartBottomRow: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    @AppStorage("unit") private var unit: Unit = .kcal

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Stats")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            Divider()
            LabeledContent("Consumed", value: "\(viewModel.caloriesConsumed.formattedValue()) \(unit.unitExtension)")
            LabeledContent("Remaining", value: "\(viewModel.caloriesRemaining.formattedValue()) \(unit.unitExtension)")
            LabeledContent("Limit", value: "\(viewModel.calorieLimit.formattedValue()) \(unit.unitExtension)")
            if let overLimit = viewModel.overLimit?.formattedValue() {
                LabeledContent("Over Limit", value: "\(overLimit) \(unit.unitExtension)")
                    .foregroundStyle(.red)
            }
        }
        .font(.subheadline)
    }
}
