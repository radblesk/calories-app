//
//  CaloriesRingsWidgets.swift
//  Calories Widgets
//
//  Created by Radoslav Bley on 23/09/2026.
//

internal import HealthKit
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

        let consumed = await HealthStoreClient.shared.fetchTodayTotal(for: .dietaryEnergyConsumed)
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
                    SemicircleProgressView(value: entry.consumed, total: entry.limit)
                        .isWidget()

                    SmallWidgetRow(title: "Remaining", symbol: "fork.knife", value: entry.limit - entry.consumed)
                        .font(.caption2)
                    SmallWidgetRow(title: "Exceeded", symbol: "chevron.right.dotted.chevron.right", value: entry.overLimit)
                        .font(.caption2)
                }
                .foregroundStyle(.white)

            case .systemMedium:
                HStack(spacing: 20) {
                    SemicircleProgressView(value: entry.consumed, total: entry.limit)
                        .secondaryValue(entry.overLimit, color: .orange)
                        .isWidget()
                        .padding(5)

                    VStack(alignment: .leading, spacing: 10) {
                        SmallWidgetRow(title: "Remaining", symbol: "fork.knife", value: entry.limit - entry.consumed)
                        SmallWidgetRow(title: "Exceeded", symbol: "chevron.right.dotted.chevron.right", value: entry.overLimit)
                    }
                    .font(.footnote)
                }
                .foregroundStyle(.white)

        #endif

        case .accessoryRectangular:
            HStack {
                SemicircleProgressView(value: entry.consumed, total: entry.limit, color: .pink)
                    .secondaryValue(entry.overLimit, color: .orange)
                    .isWidget()

                VStack(alignment: .leading, spacing: 4) {
                    Label("\((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)", systemImage: "fork.knife")
                    if let overLimit = entry.overLimit, overLimit > 0 {
                        Label("\(overLimit.formattedValue()) \(entry.unit.unitExtension)", systemImage: "chevron.right.dotted.chevron.right")
                    }
                }
                .lineLimit(1)
                #if os(iOS)
                    .labelIconToTitleSpacing(4)
                    .labelReservedIconWidth(12)
                #endif
                .font(.footnote)
                .privacySensitive()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .accessoryCircular:
            SemicircleProgressView(value: entry.consumed, total: entry.limit, color: .pink)
                .secondaryValue(entry.overLimit, color: .orange)
                .isWidget()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        case .accessoryInline:
            Text("\(entry.consumed.formattedValue()) / \((max(entry.limit - entry.consumed, 0)).formattedValue()) \(entry.unit.unitExtension)")
                .privacySensitive()
                .widgetAccentable()

        #if os(watchOS)
            case .accessoryCorner:
                Text(entry.consumed.formattedValue())
                    .privacySensitive()
                    .widgetCurvesContent(true)
                    .widgetLabel {
                        Gauge(value: 0.5, in: 0...1) {
                            Text("Label")
                        }
                        .tint(.pink)
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
                    .containerBackground(.pink.quinary, for: .widget)
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
    CalorieEntry(date: .now, consumed: 1850, limit: 1500, overLimit: 3000, unit: .kcal)
}
