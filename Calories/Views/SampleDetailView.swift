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

    var body: some View {
        NavigationStack {
            List {
                Section("Sample Details") {
                    SampleDetailRow(
                        title: "Dietary Energy",
                        value: "\(sample.kilocalories()) kcal"
                    )
                    SampleDetailRow(title: "Date", value: sample.endDate.formatted(date: .abbreviated, time: .shortened))
                    SampleDetailRow(title: "Source", value: sample.sourceRevision.source.name)
                    if let deviceName = sample.device?.name {
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
