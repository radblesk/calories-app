//
//  ChangeLimitView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI
import WidgetKit

struct ChangeLimitView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    @State private var value: Double = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Daily Limit")
                    .foregroundStyle(.pink)
                    .padding(.bottom, 4)
                    .fontWeight(.medium)

                Stepper(value.formattedValue(), value: $value.animation(), step: 10)
                    .controlSize(.small)
                    .padding(.horizontal)
                    .contentTransition(.numericText(value: value))

                Text(viewModel.unit.title.uppercased())
                    .foregroundStyle(.pink)
                    .fontWeight(.medium)

                Spacer(minLength: 0)

                Button("Set") {
                    viewModel.calorieLimit = value
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.black)
                .padding(.bottom)
                .fontWeight(.bold)
                .padding(.bottom, -30)
            }
            .tint(.pink)
            .containerBackground(.pink.gradient.tertiary, for: .navigation)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                value = viewModel.calorieLimit
            }
        }
    }
}

#Preview {
    ChangeLimitView()
        .environments()
}
