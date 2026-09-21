//
//  isToday.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

extension Date {
    var isToday: Bool {
        Calendar.current.startOfDay(for: self) == Calendar.current.startOfDay(for: .now)
    }
}
