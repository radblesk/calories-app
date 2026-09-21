//
//  sampleFormattedDate.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

extension Date {
    func sampleFormattedDate() -> String {
        let currentYear = Calendar.current.component(.year, from: .now)
        let sampleYear = Calendar.current.component(.year, from: self)

        if sampleYear == currentYear {
            return formatted(.dateTime.day().month().hour().minute())
        }
        return formatted(.dateTime.day().month().year().hour().minute())
    }
}
