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

    var body: some View {
        NavigationStack {
            List {
                Section("Weekly Stats") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 40) {
                            ChartTopRowItem(title: "Total", value: viewModel.weeklyTotal, units: "kcal")
                            ChartTopRowItem(title: "Average", value: viewModel.weeklyAverage, units: "kcal")
                            ChartTopRowItem(title: "Daily Limit", value: viewModel.calorieLimit, units: "kcal")
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
            }
            .navigationTitle("Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Add Data", systemImage: "plus") {
                    viewModel.addingData.toggle()
                }
            }
            .task {
                await viewModel.getCalories(for: .now)
            }
            .refreshable {
                await viewModel.getCalories(for: .now)
            }
            .sheet(isPresented: $viewModel.addingData) {
                NewEntryView()
            }
            .overlays()
            .environment(viewModel)
        }
    }
}
