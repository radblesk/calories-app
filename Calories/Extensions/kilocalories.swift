//
//  kilocalories.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

extension HKQuantitySample {
    func kilocalories(fractionLength: Int = 0) -> String {
        return quantity.doubleValue(for: .kilocalorie()).formatted(.number.precision(.fractionLength(fractionLength)))
    }
}
