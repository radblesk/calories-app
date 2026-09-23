//
//  Unit.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

enum Unit: String, CaseIterable, Identifiable, Codable {
    case cal, kcal, kj

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .cal:
            "Large Calories"
        case .kcal:
            "Kilocalories"
        case .kj:
            "Kilojoules"
        }
    }

    var unitExtension: String {
        switch self {
        case .cal:
            "Cal"
        case .kcal:
            "kcal"
        case .kj:
            "kJ"
        }
    }

    var hkUnit: HKUnit {
        switch self {
        case .cal:
            .largeCalorie()
        case .kcal:
            .kilocalorie()
        case .kj:
            .jouleUnit(with: .kilo)
        }
    }
}
