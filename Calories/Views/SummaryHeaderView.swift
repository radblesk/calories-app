//
//  SummaryHeaderView.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct SummaryHeaderView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 20) {
            SemicircleProgressView(value: viewModel.caloriesConsumed, total: viewModel.calorieLimit)

            VStack {
                Group {
                    if let overLimit = viewModel.overLimit, overLimit > 0 {
                        Text("\(overLimit.formattedValue()) over limit")
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(viewModel.caloriesRemaining.formattedValue()) left")
                    }
                }
                .animation(.bouncy, value: viewModel.caloriesRemaining)
                .font(.title3)

                Text("of \(viewModel.calorieLimit.formattedValue()) \(viewModel.unit.unitExtension)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .animation(.bouncy, value: viewModel.calorieLimit)
            }
            .contentTransition(.numericText())
            .fontWeight(.medium)
        }
    }
}

#Preview {
    SummaryView()
        .overlays()
        .environments()
}
