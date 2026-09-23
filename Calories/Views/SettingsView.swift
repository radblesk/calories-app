//
//  SettingsView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyLimit") private var dailyLimit: Double = 1500
    @AppStorage("unit") private var unit: Unit = .kcal

    var body: some View {
        NavigationStack {
            List {
                Section("Goals") {
                    LabeledContent {
                        HStack(spacing: 4) {
                            TextField("Daily Goal", value: $dailyLimit, format: .number.precision(.fractionLength(0)))
                                .multilineTextAlignment(.trailing)
                            Text(unit.unitExtension)
                        }
                    } label: {
                        Text("Daily Goal")
                    }
                }
            }
            .onChange(of: dailyLimit) { _, newValue in
                WatchSyncManager.shared.syncDailyLimit(newValue)
            }
            .onChange(of: unit) { _, newValue in
                WatchSyncManager.shared.syncUnit(newValue)
            }
        }
    }
}

#Preview {
    SettingsView()
}
