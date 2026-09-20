//
//  CalorieData.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct CalorieData: Identifiable, Equatable {
    let id = UUID()
    var kcal: Double? = nil
    var weight: Double? = nil
}
