//
//  SummaryView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI
import WidgetKit

struct SummaryView: View {
    @Environment(CaloriesViewModel.self) private var viewModel

    @AppStorage("unit") private var unit: Unit = .kcal

    var body: some View {
        @Bindable var viewModel = self.viewModel
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 0) {
                        Text(viewModel.caloriesConsumed.formattedValue())
                            .font(.system(size: 84))
                            .fontWeight(.semibold)
                            .animation(.bouncy, value: viewModel.caloriesConsumed)

                        Text("of \(viewModel.calorieLimit.formattedValue()) \(unit.unitExtension)")
                            .foregroundStyle(Color(.systemGray2))
                            .animation(.bouncy, value: viewModel.calorieLimit)

                        ProgressBar(value: viewModel.caloriesConsumed, total: viewModel.calorieLimit)
                            .frame(maxWidth: 300, maxHeight: 10)
                            .padding(.vertical)

                        Group {
                            if let overLimit = viewModel.overLimit {
                                Text("\(overLimit.formattedValue()) over limit")
                                    .foregroundStyle(.orange.secondary)
                            } else {
                                Text("\(viewModel.caloriesRemaining.formattedValue()) remaining")
                            }
                        }
                        .foregroundStyle(Color(.systemGray))
                        .animation(.bouncy, value: viewModel.caloriesRemaining)
                    }
                    .contentTransition(.numericText())
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundStyle(.accent.gradient)
                .listRowBackground(Color.clear)

                Section("Weekly Stats") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 40) {
                            ChartTopRowItem(title: "Total", value: viewModel.weeklyTotal)
                            ChartTopRowItem(title: "Average", value: viewModel.weeklyAverage)
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
                }
                .listRowSeparator(.hidden)

                Section {
                    NavigationLink("Show All Data") {
                        HistoricalDataView()
                    }
                    Picker("Unit", selection: $unit.animation()) {
                        ForEach(Unit.allCases) { unit in
                            Text(unit.unitExtension)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: unit) { _, newValue in
                        WatchSyncManager.shared.syncUnit(newValue)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background {
                RadialGradient(
                    colors: [Color.accentColor.opacity(0.2), Color(.systemGroupedBackground)],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Add Data", systemImage: "plus") {
                    viewModel.addingData.toggle()
                }
            }
            .task {
                await viewModel.getTodayStatistics(for: .now)
                await viewModel.getStatistics(for: .now)
                WidgetCenter.shared.reloadTimelines(ofKind: "CaloriesRingsWidgets")
            }
            .refreshable {
                await viewModel.getTodayStatistics(for: .now)
                await viewModel.getStatistics(for: .now)
                WidgetCenter.shared.reloadTimelines(ofKind: "CaloriesRingsWidgets")
            }
            .sheet(isPresented: $viewModel.addingData) {
                NewEntryView()
            }
            .overlays()
        }
    }
}

#Preview {
    SummaryView()
        .environments()
}
