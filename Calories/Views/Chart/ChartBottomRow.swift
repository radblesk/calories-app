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
            LabeledContent("Consumed", value: "\(viewModel.caloriesConsumed.formatted(.number.precision(.fractionLength(2)))) kcal")
            LabeledContent("Remaining", value: "\(viewModel.caloriesRemaining.formatted(.number.precision(.fractionLength(2)))) kcal")
            if let overLimit = viewModel.overLimit?.formatted(.number.precision(.fractionLength(2))) {
                LabeledContent("Over Limit", value: "\(overLimit) kcal")
                    .foregroundStyle(.red)
            }
        }
        .font(.subheadline)
    }
}
