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
    var weeklyTotal: Double = 0
    var weeklyAverage: Double { weeklyTotal / 7 }
    var todayStatistics: HKStatistics? = nil
    var caloriesConsumed: Double { todayStatistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0 }
    var caloriesRemaining: Double { max(calorieLimit - caloriesConsumed, 0) }

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
        await client.saveSample(for: .dietaryEnergyConsumed, unit: .kilocalorie(), count: count, at: date)
        await getCalories(for: .now)
    }

    func getCalories(for date: Date) async {
        guard let statistics = await client.fetchMostRecentSample(for: .dietaryEnergyConsumed, at: date) else { return }
        self.statistics.removeAll()
        self.weeklyTotal = 0
        self.todayStatistics = nil

        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!

        statistics.enumerateStatistics(from: startDate, to: date) { [weak self] statistics, stop in
            guard let self else { return }

            let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            self.weeklyTotal = self.weeklyTotal + value

            self.statistics.append(statistics)

            if Calendar.current.startOfDay(for: statistics.endDate) == Calendar.current.startOfDay(for: .now) {
                self.todayStatistics = statistics
            }
        }
    }
}
