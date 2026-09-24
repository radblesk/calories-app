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
        VStack(spacing: -30) {
            SemicircleProgressView(progress: viewModel.consumedProgress, lineWidth: 32)
                .frame(width: 300, height: 150)

            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    Text(viewModel.caloriesConsumed > 0 ? viewModel.caloriesConsumed.formattedValue() : "--")
                        .font(.system(size: 52))
                        .fontWeight(.heavy)
                        .animation(.bouncy, value: viewModel.caloriesConsumed)
//                        .foregroundStyle(.accent.gradient)

                    Text("of \(viewModel.calorieLimit.formattedValue()) \(viewModel.unit.unitExtension)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .animation(.bouncy, value: viewModel.calorieLimit)
                }

                Group {
                    if let overLimit = viewModel.overLimit, overLimit > 0 {
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
