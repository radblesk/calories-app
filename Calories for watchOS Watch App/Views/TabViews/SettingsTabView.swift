//
//  SettingsTabView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct SettingsTabView: View {
    @AppStorage("unit") private var unit: Unit = .kcal

    var body: some View {
        VStack {
            NavigationLink("Show All Data") {
                HistoricalDataView()
                    .containerBackground(.pink.gradient.secondary, for: .navigation)
            }
            Picker("Unit", selection: $unit) {
                ForEach(Unit.allCases) { unit in
                    Text(unit.unitExtension)
                        .tag(unit)
                }
            }
            .pickerStyle(.navigationLink)
        }
        .onChange(of: unit) { _, newValue in
            WatchSyncManager.shared.syncUnit(newValue)
        }
    }
}

#Preview {
    SettingsTabView()
}
