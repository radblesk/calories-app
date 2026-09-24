//
//  ChartBottomRow.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct ChartBottomRow: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Stats")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            Divider()
            LabeledContent("Consumed", value: "\(viewModel.caloriesConsumed.formattedValue()) \(viewModel.unit.unitExtension)")
            LabeledContent("Remaining", value: "\(viewModel.caloriesRemaining.formattedValue()) \(viewModel.unit.unitExtension)")
            LabeledContent("Limit", value: "\(viewModel.calorieLimit.formattedValue()) \(viewModel.unit.unitExtension)")
            if let overLimit = viewModel.overLimit?.formattedValue() {
                LabeledContent("Over Limit", value: "\(overLimit) \(viewModel.unit.unitExtension)")
                    .foregroundStyle(.red)
            }
        }
        .font(.subheadline)
    }
}
