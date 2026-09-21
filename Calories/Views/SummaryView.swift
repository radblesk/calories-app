//
//  SummaryView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

struct SummaryView: View {
    @State private var viewModel = CaloriesViewModel()

    @AppStorage("unit") private var unit: Unit = .kcal

    var body: some View {
        NavigationStack {
            List {
                Section("Weekly Stats") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 40) {
                            ChartTopRowItem(title: "Total", value: viewModel.weeklyTotal)
                            ChartTopRowItem(title: "Average", value: viewModel.weeklyAverage)
                            ChartTopRowItem(title: "Daily Limit", value: viewModel.calorieLimit)
                        }
                        ChartRangeView {
                            if let firstDate = viewModel.statistics.first?.endDate {
                                Text(firstDate.formatted(.dateTime.day().month()))
                            }
                            if let lastDate = viewModel.statistics.last?.endDate {
                                Text(lastDate.formatted(.dateTime.day().month()))
                            }
                            Text(Calendar.current.component(.year, from: .now).formatted(.number.grouping(.never)))
                        }
                    }
                    WeeklyChart(data: viewModel.statistics)
                    ChartBottomRow()
                }
                .listRowSeparator(.hidden)

                Section {
                    NavigationLink("Show All Data") {
                        HistoricalDataView()
                    }
                    Picker("Unit", selection: $unit) {
                        ForEach(Unit.allCases) { unit in
                            Text(unit.unitExtension)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Add Data", systemImage: "plus") {
                    viewModel.addingData.toggle()
                }
            }
            .task {
                await viewModel.getStatistics(for: .now)
            }
            .refreshable {
                await viewModel.getStatistics(for: .now)
            }
            .sheet(isPresented: $viewModel.addingData) {
                NewEntryView()
            }
            .overlays()
            .environment(viewModel)
        }
    }
}
