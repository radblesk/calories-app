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
    @Environment(CaloriesViewModel.self) private var caloriesModel

    var body: some View {
        NavigationStack {
            List {
                if viewModel.data.isEmpty {
                    ContentUnavailableView("No data", systemImage: "heart.slash")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Section(caloriesModel.unit.title) {
                        ForEach(viewModel.data, id: \.self) { sample in
                            NavigationLink {
                                SampleDetailView(sample: sample)
                            } label: {
                                LabeledContent {
                                    Text(sample.endDate.sampleFormattedDate())
                                } label: {
                                    Label {
                                        Text(sample.formattedValue(in: caloriesModel.unit))
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
            }
            .navigationTitle("Historical Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                #if !os(watchOS)
                    EditButton()
                #endif
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
