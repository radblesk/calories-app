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
        ZStack {
            RingView(progress: viewModel.consumedProgress, color: .cyan, level: 1, symbol: "fork.knife")

            RingView(progress: viewModel.overLimitProgress, color: .pink, level: 2, symbol: "chevron.right.dotted.chevron.right")

            VStack {
                Text(viewModel.caloriesRemaining.formattedValue())
                    .contentTransition(.numericText(value: viewModel.caloriesRemaining))
                    .animation(.bouncy, value: viewModel.caloriesRemaining)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(viewModel.overLimit == nil ? .primary : Color.red)
                Text(viewModel.unit.unitExtension)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
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
