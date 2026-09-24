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

struct SmallWidgetRow: View {
    let title: String
    let symbol: String
    let value: Double?

    var body: some View {
        HStack {
            Image(systemName: symbol)
                .symbolRenderingMode(.hierarchical)
            Text(title)
            Spacer()
            if let value, value > 0 {
                Text(value.formattedValue())
            } else {
                Text("--")
            }
        }
        .privacySensitive()
    }
}

struct CaloriesRingsWidgetsEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        #if os(iOS)
            case .systemSmall:
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: -10) {
                        SemicircleProgressView(progress: entry.consumed / entry.limit, lineWidth: 18)

                        Text(entry.consumed > 0 ? entry.consumed.formattedValue() : "--")
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                    }
                    .padding(.horizontal, 10)

                    Spacer(minLength: 0)

                    SmallWidgetRow(title: "Remaining", symbol: "fork.knife", value: entry.limit - entry.consumed)
                        .font(.caption2)
                    SmallWidgetRow(title: "Over Limit", symbol: "chevron.right.dotted.chevron.right", value: entry.overLimit)
                        .font(.caption2)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            case .systemMedium:
                HStack(spacing: 20) {
                    VStack(spacing: -10) {
                        SemicircleProgressView(progress: entry.consumed / entry.limit, lineWidth: 18)

                        Text(entry.consumed > 0 ? entry.consumed.formattedValue() : "--")
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 150)

                    VStack(alignment: .leading, spacing: 10) {
                        SmallWidgetRow(title: "Remaining", symbol: "fork.knife", value: entry.limit - entry.consumed)
                        SmallWidgetRow(title: "Over Limit", symbol: "chevron.right.dotted.chevron.right", value: entry.overLimit)
                    }
                    .font(.footnote)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

        #endif

        case .accessoryRectangular:
            #if os(watchOS)
                HStack {
                    ZStack {
                        Ring(progress: entry.consumed / entry.limit, level: 1)
                            .isWidget()
                            .lineWidth(8)
                        Ring(progress: (entry.overLimit ?? 0) / entry.limit, level: 2)
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
                        Ring(progress: entry.consumed / entry.limit, level: 1)
                            .isWidget()
                            .lineWidth(10)
                        Ring(progress: (entry.overLimit ?? 0) / entry.limit, level: 2)
                            .isWidget()
                            .lineWidth(10)
                    }
                    .frame(maxWidth: 50)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(entry.consumed.formattedValue()) \(entry.unit.unitExtension)")
                        Text("\((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)")
                        if let overLimit = entry.overLimit, overLimit > 0 {
                            Text(overLimit.formattedValue())
                        }
                    }
                    .privacySensitive()
                }
            #endif

        case .accessoryCircular:
            #if os(watchOS)
                ZStack {
                    Ring(progress: entry.consumed / entry.limit, level: 1)
                        .isWidget()
                        .lineWidth(8)
                    Ring(progress: (entry.overLimit ?? 0) / entry.limit, level: 2)
                        .isWidget()
                        .lineWidth(8)
                }
                .padding(4)
                .widgetAccentable()
            #else
                ZStack {
                    Ring(progress: entry.consumed / entry.limit, level: 1)
                        .isWidget()
                        .lineWidth(8)
                    Ring(progress: (entry.overLimit ?? 0) / entry.limit, level: 2)
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
                    .containerBackground(
                        LinearGradient(colors: [.accent.mix(with: .black, by: 0.6), .black], startPoint: .top, endPoint: .bottom),
                        for: .widget
                    )
                #endif
        }
        .configurationDisplayName("Calories Rings")
        .description("See your dietary activity.")
        #if os(watchOS)
            .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline, .accessoryCorner])
        #elseif os(iOS)
            .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium])
        #endif
    }
}

#Preview(as: .accessoryRectangular) {
    CaloriesRingsWidgets()
} timeline: {
    CalorieEntry(date: .now, consumed: 1850, limit: 1500, overLimit: 300, unit: .kcal)
}
