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
    var weeklyAverage: Double { weeklyTotal / 7 }
    var todayStatistics: HKStatistics? { getTodaySample() }
    var caloriesConsumed: Double {
        todayStatistics?.sumQuantity()?.doubleValue(for: (UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal).hkUnit) ?? 0
    }
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
        await client.saveSample(for: .dietaryEnergyConsumed, count: count, at: date)
        await getStatistics(for: .now)
    }

    func getStatistics(for date: Date) async {
        guard
            let statistics = await client.fetchStatistics(
                for: .dietaryEnergyConsumed,
                from: Calendar.current.date(byAdding: .day, value: -7, to: date)!,
                to: nil
            )
        else { return }
        self.statistics.removeAll()

        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!

        statistics.enumerateStatistics(from: startDate, to: date) { [weak self] statistics, stop in
            guard let self else { return }
            self.statistics.append(statistics)
        }
    }

    private func calculateWeeklyTotal() -> Double {
        var total: Double = 0
        for item in statistics {
            total = total + item.extractedValue()
        }
        return total
    }

    private func getTodaySample() -> HKStatistics? {
        return statistics.first(where: { $0.endDate.isToday })
    }
}
