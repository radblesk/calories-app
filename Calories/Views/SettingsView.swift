//
//  SettingsView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyLimit") private var dailyLimit: Double = 1500

    var body: some View {
        NavigationStack {
            List {
                Section("Goals") {
                    LabeledContent {
                        HStack(spacing: 4) {
                            TextField("Daily Goal", value: $dailyLimit, format: .number.precision(.fractionLength(0)))
                                .multilineTextAlignment(.trailing)
                            Text("kcal")
                        }
                    } label: {
                        Text("Daily Goal")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
