//
//  ActiveTab.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

enum ActiveTab: String, Identifiable {
    case rings, todaySummary, statistics, weeklySummary, settings

    var id: String { self.rawValue }

    static let visibleTabs: [ActiveTab] = [.rings, .todaySummary, .statistics, .weeklySummary, .settings]

    var tabColor: Color {
        switch self {
        case .rings:
            .pink.opacity(0.5)
        case .todaySummary:
            .pink
        case .statistics:
            .pink
        case .weeklySummary:
            .green
        case .settings:
            .gray.opacity(0.5)
        }
    }

    @ContentBuilder
    var tabContent: some View {
        switch self {
        case .rings:
            RingsTabView()
        case .todaySummary:
            TodaySummaryTabView()
        case .statistics:
            StatisticsTabView()
        case .weeklySummary:
            WeeklySummaryTabView()
        case .settings:
            SettingsTabView()
        }
    }
}
