//
//  CaloriesRingsWidgets.swift
//  Calories Widgets
//
//  Created by Radoslav Bley on 23/09/2026.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalorieEntry {
        CalorieEntry(date: Date(), consumed: 0, limit: 1500, overLimit: 0, unit: .kcal)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalorieEntry) -> Void) {
        Task {
            completion(await loadEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalorieEntry>) -> Void) {
        Task {
            let entry = await loadEntry()
            completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
        }
    }

    private func loadEntry() async -> CalorieEntry {
        let store = CaloriesViewModel.shared
        store.loadPersistedSettings()
        await store.getTodayStatistics(for: .now)

        let consumed = store.caloriesConsumed
        let limit = store.calorieLimit
        let overLimit = store.overLimit

        return CalorieEntry(date: .now, consumed: consumed, limit: limit, overLimit: overLimit, unit: store.unit)
    }
}

struct CalorieEntry: TimelineEntry {
    let date: Date

    let consumed: Double
    let limit: Double
    let overLimit: Double?
    let unit: Unit
}

struct CaloriesRingsWidgetsEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        #if os(iOS)
            case .systemSmall:
                VStack(alignment: .leading) {
                    ZStack {
                        RingView(progress: entry.consumed / entry.limit, color: .cyan, level: 1, symbol: nil)
                            .isWidget()
                            .lineWidth(10)
                        RingView(progress: (entry.overLimit ?? 0) / entry.limit, color: .pink, level: 2, symbol: nil)
                            .isWidget()
                            .lineWidth(10)
                    }
                    .frame(maxHeight: 60)
                    .widgetAccentable()

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Label("\(entry.consumed.formattedValue()) \(entry.unit.unitExtension)", systemImage: "fork.knife")
                            .foregroundStyle(.cyan)
                        Label("\((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)", systemImage: "arrow.up")
                            .foregroundStyle(.green)
                        if let overLimit = entry.overLimit, overLimit > 0 {
                            Label(overLimit.formattedValue(), systemImage: "plus")
                                .foregroundStyle(.pink)
                        }
                    }
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .privacySensitive()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        #endif

        case .accessoryRectangular:
            #if os(watchOS)
                HStack {
                    ZStack {
                        RingView(progress: entry.consumed / entry.limit, color: .cyan, level: 1, symbol: nil)
                            .isWidget()
                            .lineWidth(8)
                        RingView(progress: (entry.overLimit ?? 0) / entry.limit, color: .pink, level: 2, symbol: nil)
                            .isWidget()
                            .lineWidth(8)
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(entry.consumed.formattedValue()) \(entry.unit.unitExtension)")
                            .foregroundStyle(.cyan)
                        Text("\((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)")
                            .foregroundStyle(.green)
                        if let overLimit = entry.overLimit, overLimit > 0 {
                            Text(overLimit.formattedValue())
                                .foregroundStyle(.pink)
                        }
                    }
                    .privacySensitive()

                    Spacer()
                }
            #else
                HStack(spacing: 12) {
                    ZStack {
                        RingView(progress: entry.consumed / entry.limit, color: .cyan, level: 1, symbol: nil)
                            .isWidget()
                            .lineWidth(8)
                        RingView(progress: (entry.overLimit ?? 0) / entry.limit, color: .pink, level: 2, symbol: nil)
                            .isWidget()
                            .lineWidth(8)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(entry.consumed.formattedValue()) \(entry.unit.unitExtension)")
                            .foregroundStyle(.cyan)
                        Text("\((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)")
                            .foregroundStyle(.green)
                        if let overLimit = entry.overLimit, overLimit > 0 {
                            Text(overLimit.formattedValue())
                                .foregroundStyle(.pink)
                        }
                    }
                    .privacySensitive()
                }
            #endif

        case .accessoryCircular:
            #if os(watchOS)
                ZStack {
                    RingView(progress: entry.consumed / entry.limit, color: .cyan, level: 1, symbol: nil)
                        .isWidget()
                        .lineWidth(8)
                    RingView(progress: (entry.overLimit ?? 0) / entry.limit, color: .pink, level: 2, symbol: nil)
                        .isWidget()
                        .lineWidth(8)
                }
                .padding(4)
                .widgetAccentable()
            #else
                ZStack {
                    RingView(progress: entry.consumed / entry.limit, color: .cyan, level: 1, symbol: nil)
                        .isWidget()
                        .lineWidth(8)
                    RingView(progress: (entry.overLimit ?? 0) / entry.limit, color: .pink, level: 2, symbol: nil)
                        .isWidget()
                        .lineWidth(8)
                }
                .widgetAccentable()
            #endif

        case .accessoryInline:
            Text("\(entry.consumed.formattedValue())/\((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)")
                .privacySensitive()

        #if os(watchOS)
            case .accessoryCorner:
                Text(entry.consumed.formattedValue())
                    .privacySensitive()
                    .widgetCurvesContent(true)
                    .widgetLabel {
                        Gauge(value: 0.5, in: 0...1) {
                            Text("Label")
                        }
                        .tint(.cyan)
                    }
                    .widgetAccentable()
        #endif

        default: EmptyView()
        }
    }
}

struct CaloriesRingsWidgets: Widget {
    let kind: String = "CaloriesRingsWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CaloriesRingsWidgetsEntryView(entry: entry)
                #if os(watchOS)
                    .containerBackground(.fill.tertiary, for: .widget)
                #else
                    .containerBackground(.black.gradient, for: .widget)
                #endif
        }
        .configurationDisplayName("Calories Rings")
        .description("See your dietary activity.")
        #if os(watchOS)
            .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline, .accessoryCorner])
        #elseif os(iOS)
            .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall])
        #endif
    }
}

#Preview(as: .accessoryRectangular) {
    CaloriesRingsWidgets()
} timeline: {
    CalorieEntry(date: .now, consumed: 1850, limit: 1500, overLimit: nil, unit: .kcal)
}
