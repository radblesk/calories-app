//
//  formattedValue.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

extension HKQuantitySample {
    func formattedValue(in unit: Unit, fractionLength: Int = 0, grouping: NumberFormatStyleConfiguration.Grouping = .automatic) -> String {
        return quantity.doubleValue(for: unit.hkUnit).formatted(.number.locale(Locale(identifier: "en_US")).precision(.fractionLength(0...fractionLength)).grouping(grouping))
    }
}

extension HKStatistics {
    func formattedValue(in unit: Unit, fractionLength: Int = 0, grouping: NumberFormatStyleConfiguration.Grouping = .automatic) -> String {
        let value = sumQuantity()?.doubleValue(for: unit.hkUnit) ?? 0
        return value.formatted(.number.locale(Locale(identifier: "en_US")).precision(.fractionLength(0...fractionLength)).grouping(grouping))
    }
    func extractedValue(in unit: Unit, ) -> Double {
        return sumQuantity()?.doubleValue(for: unit.hkUnit) ?? 0
    }
}

extension Double {
    func formattedValue(fractionLength: Int = 0, grouping: NumberFormatStyleConfiguration.Grouping = .automatic) -> String {
        return formatted(.number.locale(Locale(identifier: "en_US")).precision(.fractionLength(0...fractionLength)).grouping(grouping))
    }
}
