//
//  CaloriesViewModel.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

internal import HealthKit
import SwiftUI

@Observable
final class CaloriesViewModel {
    let client = HealthStoreClient.shared

    // Data

    var statistics: [HKStatistics] = []
    var weeklyTotal: Double { calculateWeeklyTotal() }
    var weeklyAverage: Double { calculateWeeklyAverage() }
    var todayStatistics: [HKStatistics] = []
    var caloriesConsumed: Double { todayStatistics.map { $0.extractedValue() }.reduce(0, +) }
    var caloriesRemaining: Double { max(calorieLimit - caloriesConsumed, 0) }
    var consumedProgress: Double { caloriesConsumed / calorieLimit }
    var overLimitProgress: Double { (overLimit ?? 0) / calorieLimit }

    // Goals/Limits

    var calorieLimit: Double {
        UserDefaults.standard.object(forKey: "dailyLimit") as? Double ?? 1500
    }
    var overLimit: Double? {
        let remaining = calorieLimit - caloriesConsumed
        return remaining < 0 ? abs(remaining) : nil
    }

    // States

    var addingData: Bool = false

    // MARK: - Methods

    func saveCalories(_ count: Double, at date: Date) async {
        await client.saveSample(for: .dietaryEnergyConsumed, count: count, at: date)
        await getStatistics(for: .now)
    }

    func getStatistics(for date: Date) async {
        guard
            let statistics = await client.fetchStatistics(
                for: .dietaryEnergyConsumed,
                from: Calendar.current.date(byAdding: .day, value: -7, to: date)!,
                to: nil,
                interval: DateComponents(day: 1)
            )
        else { return }
        self.statistics.removeAll()

        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!

        statistics.enumerateStatistics(from: startDate, to: date) { [weak self] statistics, stop in
            guard let self else { return }
            self.statistics.append(statistics)
        }
    }

    func getTodayStatistics(for date: Date) async {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard
            let statistics = await client.fetchStatistics(
                for: .dietaryEnergyConsumed,
                from: startOfDay,
                to: date,
                interval: DateComponents(minute: 30)
            )
        else { return }
        self.todayStatistics.removeAll()

        statistics.enumerateStatistics(from: startOfDay, to: date) { [weak self] statistics, stop in
            guard let self else { return }
            self.todayStatistics.append(statistics)
        }
    }

    private func calculateWeeklyTotal() -> Double {
        var total: Double = 0
        for item in statistics {
            total = total + item.extractedValue()
        }
        return total
    }

    private func calculateWeeklyAverage() -> Double {
        let values =
            statistics
            .map { $0.extractedValue() }
            .filter { !$0.isZero }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    private func getTodaySample() -> HKStatistics? {
        return statistics.first(where: { $0.endDate.isToday })
    }
}
