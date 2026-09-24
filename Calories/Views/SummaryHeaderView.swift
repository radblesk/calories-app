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
        VStack(spacing: -50) {
            SemicircleProgressView(progress: viewModel.caloriesConsumed / viewModel.calorieLimit)
                .frame(width: 300, height: 150)

            VStack(spacing: 20) {
                VStack(spacing: -5) {
                    Text(viewModel.caloriesConsumed.formattedValue())
                        .font(.system(size: 84))
                        .fontWeight(.semibold)
                        .animation(.bouncy, value: viewModel.caloriesConsumed)
                        .foregroundStyle(.accent.gradient)

                    Text("of \(viewModel.calorieLimit.formattedValue()) \(viewModel.unit.unitExtension)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .animation(.bouncy, value: viewModel.calorieLimit)
                }

                Group {
                    if let overLimit = viewModel.overLimit {
                        Text("\(overLimit.formattedValue()) over limit")
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(viewModel.caloriesRemaining.formattedValue()) left")
                    }
                }
                .animation(.bouncy, value: viewModel.caloriesRemaining)
                .font(.headline)
            }
            .contentTransition(.numericText())
            .fontWeight(.medium)
        }
    }
}

#Preview {
    SummaryView()
        .environments()
}
