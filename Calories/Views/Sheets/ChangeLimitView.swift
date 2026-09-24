//
//  ChangeLimitView.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct ChangeLimitView: View {
    @Environment(CaloriesViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var value: Double = 0

    var body: some View {
        NavigationStack {
            AdaptiveView {
                VStack(alignment: .leading) {
                    headerText
                    Spacer()
                    stepper
                    Spacer()
                    footer
                }
            } secondary: {
                HStack(alignment: .firstTextBaseline, spacing: 100) {
                    headerText
                    VStack {
                        stepper
                        Spacer()
                        footer
                    }
                }
            }
            .padding(32)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                value = viewModel.calorieLimit
            }
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading) {
            Text("Daily Calories Limit")
                .font(.title2)
                .fontWeight(.bold)

            Text("Set a limit based on how fat you are and how fast you want to loose weight, piggy.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var stepper: some View {
        VStack {
            CustomStepper(value: $value)

            Text("\(viewModel.unit.title.uppercased())/DAY")
                .font(.title3)
                .fontWeight(.bold)
                .kerning(1.5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ContentBuilder
    private var footer: some View {
        Text("Your limits will update across your devices when your paired Apple Watch is unlocked.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.bottom, 10)

        Button("Change Calories Limit") {
            viewModel.calorieLimit = value
            dismiss()
        }
        .buttonStyle(.glass)
        .buttonSizing(.flexible)
        .controlSize(.large)
        .fontWeight(.medium)
        .padding(.bottom, -30)
    }
}

enum StepperDirection {
    case decrease, increase
}

#Preview {
    ChangeLimitView()
        .environments()
}
