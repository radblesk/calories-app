//
//  RingsTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct RingsTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 10) {
            SemicircleProgressView(value: viewModel.caloriesConsumed, total: viewModel.calorieLimit, color: .pink)
                .padding(10)

            Group {
                if let overLimit = viewModel.overLimit, overLimit > 0 {
                    Text("\(overLimit.formattedValue()) over limit")
                        .foregroundStyle(.orange)
                        .contentTransition(.numericText(value: overLimit))
                        .animation(.bouncy, value: overLimit)
                } else {
                    Text("\(viewModel.caloriesRemaining.formattedValue()) left")
                        .contentTransition(.numericText(value: viewModel.caloriesRemaining))
                        .animation(.bouncy, value: viewModel.caloriesRemaining)
                }
            }
            .fontWeight(.medium)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button("Add Data", systemImage: "plus") {
                    viewModel.addingData.toggle()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environments()
}
