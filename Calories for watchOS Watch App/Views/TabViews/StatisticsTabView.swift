//
//  StatisticsTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct StatisticsTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel
    @State private var changingLimit: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            StatisticsRowView(title: "Consumed", value: viewModel.caloriesConsumed)
            Divider()
            StatisticsRowView(title: "Remaining", value: viewModel.caloriesRemaining)
            if let overLimit = viewModel.overLimit {
                Divider()
                StatisticsRowView(title: "Over Limit", value: overLimit)
            }
        }
        .padding(.horizontal)
        .navigationTitle("Today")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button("Change Limit", systemImage: "plusminus.circle") {
                    changingLimit.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $changingLimit) {
            StepperView()
        }
    }
}

#Preview {
    StatisticsTabView()
        .environments()
}
