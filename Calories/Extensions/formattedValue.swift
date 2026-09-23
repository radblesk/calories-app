//
//  formattedValue.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

extension HKQuantitySample {
    func formattedValue(fractionLength: Int = 0, grouping: NumberFormatStyleConfiguration.Grouping = .automatic) -> String {
        let unit =
            UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal
        return quantity.doubleValue(for: unit.hkUnit).formatted(.number.precision(.fractionLength(0...fractionLength)).grouping(grouping))
    }
}

extension HKStatistics {
    func formattedValue(fractionLength: Int = 0, grouping: NumberFormatStyleConfiguration.Grouping = .automatic) -> String {
        let unit =
            UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal
        let value = sumQuantity()?.doubleValue(for: unit.hkUnit) ?? 0
        return value.formatted(.number.precision(.fractionLength(0...fractionLength)).grouping(grouping))
    }
    func extractedValue() -> Double {
        let unit =
            UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal
        return sumQuantity()?.doubleValue(for: unit.hkUnit) ?? 0
    }
}

extension Double {
    func formattedValue(fractionLength: Int = 0, grouping: NumberFormatStyleConfiguration.Grouping = .automatic) -> String {
        return formatted(.number.precision(.fractionLength(0...fractionLength)).grouping(grouping))
    }
}
