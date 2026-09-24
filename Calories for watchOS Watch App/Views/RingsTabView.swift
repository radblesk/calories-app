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
            Ring(progress: viewModel.consumedProgress, level: 1)
                .showSymbol()
            Ring(progress: viewModel.overLimitProgress, level: 2)
                .showSymbol()

            VStack {
                Text(viewModel.caloriesRemaining > 0 ? viewModel.caloriesRemaining.formattedValue() : "--")
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
