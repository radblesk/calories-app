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
                    .foregroundStyle(.cyan)
                    .padding(.bottom, 4)

                Stepper(value.formattedValue(), value: $value, step: 10)
                    .controlSize(.small)
                    .padding(.horizontal)

                Text(viewModel.unit.title.uppercased())
                    .foregroundStyle(.cyan)

                Spacer()

                Button("Set") {
                    viewModel.calorieLimit = value
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.black)
                .padding(.bottom)
            }
            .ignoresSafeArea(edges: .bottom)
            .tint(.cyan)
            .containerBackground(.cyan.gradient.tertiary, for: .navigation)
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
}
