//
//  SettingsTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct SettingsTabView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = self.viewModel
        VStack {
            NavigationLink("Show All Data") {
                HistoricalDataView()
                    .containerBackground(.pink.gradient.secondary, for: .navigation)
            }
            Picker("Unit", selection: $viewModel.unit) {
                ForEach(Unit.allCases) { unit in
                    Text(unit.unitExtension)
                        .tag(unit)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }
}

#Preview {
    SettingsTabView()
}
