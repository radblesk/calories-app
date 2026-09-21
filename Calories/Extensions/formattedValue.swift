//
//  formattedValue.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

extension HKQuantitySample {
    func formattedValue(fractionLength: Int = 0) -> String {
        let unit =
            UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal
        return quantity.doubleValue(for: unit.hkUnit).formatted(.number.precision(.fractionLength(fractionLength)))
    }
}

extension HKStatistics {
    func formattedValue(fractionLength: Int = 0) -> String {
        let unit =
            UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal
        let value = sumQuantity()?.doubleValue(for: unit.hkUnit) ?? 0
        return value.formatted(.number.precision(.fractionLength(fractionLength)))
    }
    func extractedValue() -> Double {
        let unit =
            UserDefaults.standard.string(forKey: "unit")
            .flatMap(Unit.init(rawValue:)) ?? .kcal
        return sumQuantity()?.doubleValue(for: unit.hkUnit) ?? 0
    }
}
