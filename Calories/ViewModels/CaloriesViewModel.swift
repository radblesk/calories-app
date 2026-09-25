//
//  CaloriesViewModel.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

internal import HealthKit
import SwiftUI
import WidgetKit

@Observable
final class CaloriesViewModel {
    static let shared = CaloriesViewModel()
    let defaults = SharedStorage.defaults

    private init() {
        restoreDefaults()
    }

    let client = HealthStoreClient.shared

    // Data

    /// Weekly
    var statistics: [HKStatistics] = []
    var weeklyTotal: Double { calculateWeeklyTotal() }
    var weeklyAverage: Double { calculateWeeklyAverage() }

    /// Today
    var todayStatistics: [HKStatistics] = []
    var caloriesConsumed: Double { todayStatistics.map { $0.extractedValue(in: unit) }.reduce(0, +) }
    var caloriesRemaining: Double { max(calorieLimit - caloriesConsumed, 0) }
    var consumedProgress: Double { caloriesConsumed / calorieLimit }
    var overLimitProgress: Double { (overLimit ?? 0) / calorieLimit }
    var overLimit: Double? {
        let remaining = calorieLimit - caloriesConsumed
        return remaining < 0 ? abs(remaining) : nil
    }

    // Goals/Limits

    var calorieLimit: Double = 0 {
        didSet {
            setLimit(calorieLimit)
        }
    }

    // Units

    var unit: Unit = .kcal {
        didSet {
            setUnit(unit)
        }
    }

    // States

    var addingData: Bool = false
    var changingLimit: Bool = false

    // Settings

    private var settingsModifiedAt: Double {
        get {
            defaults.double(forKey: "settingsModifiedAt")
        }
        set {
            defaults.set(newValue, forKey: "settingsModifiedAt")
        }
    }
    private var isApplyingRemoteSettings: Bool = false

    // Tasks

    private var weeklyStatisticsTask: Task<Void, Never>?
    private var todayStatisticsTask: Task<Void, Never>?

    // MARK: - Methods

    func getStatistics(for date: Date) async {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: date)!
        let startDate = Calendar.current.startOfDay(for: weekAgo)

        weeklyStatisticsTask?.cancel()
        weeklyStatisticsTask = Task {
            do {
                let stream = client.fetchStatistics(for: .dietaryEnergyConsumed, from: startDate, to: nil, interval: DateComponents(day: 1))

                for try await statisticsCollection in stream {
                    guard let collection = statisticsCollection else { continue }

                    var newStats: [HKStatistics] = []
                    collection.enumerateStatistics(from: startDate, to: date) { statistics, stop in
                        newStats.append(statistics)
                    }
                    self.statistics = newStats
                    reloadWidgets()
                }
            } catch {
                print("Error fetching statistics")
            }
        }
    }

    func getTodayStatistics(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)

        todayStatisticsTask?.cancel()
        todayStatisticsTask = Task {
            do {
                let stream = client.fetchStatistics(
                    for: .dietaryEnergyConsumed,
                    from: startOfDay,
                    to: endOfDay,
                    interval: DateComponents(minute: 30)
                )

                for try await statisticsCollection in stream {
                    guard let collection = statisticsCollection else { continue }

                    var newStats: [HKStatistics] = []
                    collection.enumerateStatistics(from: startOfDay, to: .now) { statistics, stop in
                        newStats.append(statistics)
                    }
                    self.todayStatistics = newStats
                    reloadWidgets()
                }
            } catch {
                print("Error fetching statistics")
            }
        }
    }

    func storeCalories(_ count: Double, at date: Date) async {
        await client.saveSample(for: .dietaryEnergyConsumed, count: count, at: date)
    }

    func cancelTasks() {
        weeklyStatisticsTask?.cancel()
        weeklyStatisticsTask = nil
        todayStatisticsTask?.cancel()
        todayStatisticsTask = nil
    }

    // MARK: - WCSession Helpers

    func applyRemoteSettings(unit: Unit, limit: Double, modifiedAt: Double) {
        guard modifiedAt > settingsModifiedAt else { return }
        isApplyingRemoteSettings = true
        self.unit = unit
        self.calorieLimit = limit
        self.settingsModifiedAt = modifiedAt
        isApplyingRemoteSettings = false
    }

    // MARK: - Widgets Helpers

    func loadPersistentData() {
        restoreDefaults()
    }

    // MARK: - Helpers Methods

    private func setLimit(_ value: Double) {
        defaults.set(calorieLimit, forKey: "dailyLimit")
        reloadWidgets()
        guard !isApplyingRemoteSettings else { return }
        settingsModifiedAt = Date.now.timeIntervalSince1970
        WatchSyncManager.shared.syncSettings(unit: unit, limit: value, modifiedAt: settingsModifiedAt)
    }

    private func setUnit(_ value: Unit) {
        if let encoded = try? JSONEncoder().encode(value) {
            defaults.set(encoded, forKey: "unit")
        }
        reloadWidgets()

        guard !isApplyingRemoteSettings else { return }
        settingsModifiedAt = Date.now.timeIntervalSince1970
        WatchSyncManager.shared.syncSettings(unit: value, limit: calorieLimit, modifiedAt: settingsModifiedAt)
    }

    private func restoreDefaults() {
        let decoder = JSONDecoder()

        if let savedUnit = defaults.data(forKey: "unit"),
            let decodedUnit = try? decoder.decode(Unit.self, from: savedUnit)
        {
            self.unit = decodedUnit
        }

        calorieLimit = defaults.object(forKey: "dailyLimit") as? Double ?? 1500
//        reloadWidgets()
    }

    private func calculateWeeklyTotal() -> Double {
        var total: Double = 0
        for item in statistics {
            total = total + item.extractedValue(in: unit)
        }
        return total
    }

    private func calculateWeeklyAverage() -> Double {
        let values =
            statistics
            .map { $0.extractedValue(in: unit) }
            .filter { !$0.isZero }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "CaloriesRingsWidgets")
    }
}
