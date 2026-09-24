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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var offset: Double = 0

    var body: some View {
        @Bindable var viewModel = self.viewModel
        NavigationStack {
            AdaptiveView {
                portraitView
            } secondary: {
                landscapeView
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Change Limit", systemImage: "plusminus.circle") {
                        viewModel.changingLimit.toggle()
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Data", systemImage: "plus") {
                        viewModel.addingData.toggle()
                    }
                    .tint(.accent)
                    .buttonStyle(.borderedProminent)
                }
            }
            .background {
                if colorScheme == .dark {
                    RadialGradient(
                        colors: [Color.accentColor.opacity(0.2), Color(.systemGroupedBackground)],
                        center: horizontalSizeClass == .compact ? .top : .trailing,
                        startRadius: 0,
                        endRadius: 500
                    )
                    .ignoresSafeArea()
                } else {
                    Rectangle()
                        .fill(Color.accent.gradient.opacity(0.1))
                        .ignoresSafeArea()
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
        }
    }

    @ContentBuilder
    private var portraitView: some View {
        List {
            Section {
                SummaryHeaderView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(y: offset)
                    .opacity(1 - (offset / 40))
                    .safeAreaPadding(.vertical)

            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listSectionMargins(.all, 0)

            Section("Weekly Stats") {
                WeeklyStatsView()
            }
            .listRowSeparator(.hidden)

            Section {
                footerView
            }
        }
        .headerProminence(.increased)
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.y + geo.contentInsets.top
        } action: { oldValue, newValue in
            print(newValue)
            offset = max(0, newValue / 6)
        }
    }

    @ContentBuilder
    private var landscapeView: some View {
        HStack {
            List {
                Section("Weekly Stats") {
                    WeeklyStatsView()
                }
                .listRowSeparator(.hidden)

                Section {
                    footerView
                }
            }
            .headerProminence(.increased)

            .frame(maxWidth: .infinity)
            .scrollEdgeEffectStyle(.soft, for: .top)

            SummaryHeaderView()
                .frame(maxWidth: .infinity)
        }
    }

    @ContentBuilder
    private var footerView: some View {
        @Bindable var viewModel = self.viewModel
        NavigationLink("Show All Data") {
            HistoricalDataView()
        }
        Picker("Unit", selection: $viewModel.unit.animation()) {
            ForEach(Unit.allCases) { unit in
                Text(unit.unitExtension)
                    .tag(unit)
            }
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    SummaryView()
        .environments()
}
