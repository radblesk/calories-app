//
//  SampleDetailView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

struct SampleDetailView: View {
    let sample: HKQuantitySample
    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Sample Details") {
                    SampleDetailRow(
                        title: "Dietary Energy",
                        value: "\(sample.formattedValue(in: viewModel.unit)) \(viewModel.unit.unitExtension)"
                    )
                    SampleDetailRow(title: "Date", value: sample.endDate.formatted(date: .abbreviated, time: .shortened))
                    SampleDetailRow(title: "Source", value: sample.sourceRevision.source.name)
                    if let deviceName = sample.sourceRevision.productType {
                        SampleDetailRow(title: "Device", value: deviceName)
                    }
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SampleDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .foregroundStyle(.gray)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(value)
        }
    }
}
