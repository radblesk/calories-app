//
//  HistoricalDataView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

struct HistoricalDataView: View {
    @State private var viewModel = HistoricalDataViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Kilocalories") {
                    ForEach(viewModel.data, id: \.self) { sample in
                        NavigationLink {
                            SampleDetailView(sample: sample)
                        } label: {
                            LabeledContent {
                                Text(sample.endDate.sampleFormattedDate())
                            } label: {
                                Label {
                                    Text(sample.kilocalories())
                                } icon: {
                                    Image(.caloriesIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 26, height: 26)
                                }

                            }
                        }
                    }
                    .onDelete(perform: viewModel.remove)
                }
            }
            .navigationTitle("Historical Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .task {
                await viewModel.fetchRecords(for: .dietaryEnergyConsumed)
            }
        }
    }
}

#Preview {
    HistoricalDataView()
        .environments()
}
