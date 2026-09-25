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
    static let defaults = UserDefaults(suiteName: "group.com.radobley.Calories") ?? .standard

    private var isApplyingRemoteSettings = false
    private var isLoadingPersistedSettings = false

    private init() {
        let legacyDefaults = UserDefaults.standard
        let savedLimit =
            Self.defaults.object(forKey: "dailyLimit") as? Double
            ?? legacyDefaults.object(forKey: "dailyLimit") as? Double
        let savedUnit =
            Self.defaults.string(forKey: "unit")
            ?? legacyDefaults.string(forKey: "unit")

        calorieLimit = savedLimit ?? 1500
        unit = savedUnit.flatMap(Unit.init(rawValue:)) ?? .kcal

        Self.defaults.set(calorieLimit, forKey: "dailyLimit")
        Self.defaults.set(unit.rawValue, forKey: "unit")
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

    // Goals/Limits

    var calorieLimit: Double {
        didSet {
            guard !isLoadingPersistedSettings else { return }
            Self.defaults.set(calorieLimit, forKey: "dailyLimit")
            Self.defaults.synchronize()
            if !isApplyingRemoteSettings {
                WatchSyncManager.shared.syncDailyLimit(calorieLimit)
            }
            reloadWidgets()
        }
    }
    var overLimit: Double? {
        let remaining = calorieLimit - caloriesConsumed
        return remaining < 0 ? abs(remaining) : nil
    }

    // Units

    var unit: Unit {
        didSet {
            guard !isLoadingPersistedSettings else { return }
            Self.defaults.set(unit.rawValue, forKey: "unit")
            Self.defaults.synchronize()
            if !isApplyingRemoteSettings {
                WatchSyncManager.shared.syncUnit(unit)
            }
            reloadWidgets()
        }
    }

    // States

    var addingData: Bool = false
    var changingLimit: Bool = false

    // Tasks

    private var weeklyStatisticsTask: Task<Void, Never>?
    private var todayStatisticsTask: Task<Void, Never>?

    // MARK: - Methods

    /// Reloads settings that may have been changed by the containing app while
    /// this process was kept alive, as is common for WidgetKit extensions.
    func loadPersistedSettings() {
        Self.defaults.synchronize()
        isLoadingPersistedSettings = true
        defer { isLoadingPersistedSettings = false }

        calorieLimit = Self.defaults.object(forKey: "dailyLimit") as? Double ?? 1500
        unit = Self.defaults.string(forKey: "unit").flatMap(Unit.init(rawValue:)) ?? .kcal
    }

    func applyRemoteSettings(dailyLimit: Double?, unit: Unit?) {
        isApplyingRemoteSettings = true
        if let dailyLimit {
            calorieLimit = dailyLimit
        }
        if let unit {
            self.unit = unit
        }
        isApplyingRemoteSettings = false
    }

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

        todayStatisticsTask?.cancel()
        todayStatisticsTask = Task {
            do {
                let stream = client.fetchStatistics(
                    for: .dietaryEnergyConsumed,
                    from: startOfDay,
                    to: date,
                    interval: DateComponents(minute: 30)
                )

                for try await statisticsCollection in stream {
                    guard let collection = statisticsCollection else { continue }

                    var newStats: [HKStatistics] = []
                    collection.enumerateStatistics(from: startOfDay, to: date) { statistics, stop in
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

    // MARK: - Helpers Methods

    func cancelTasks() {
        weeklyStatisticsTask?.cancel()
        weeklyStatisticsTask = nil
        todayStatisticsTask?.cancel()
        todayStatisticsTask = nil
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
