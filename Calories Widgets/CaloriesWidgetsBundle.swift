//
//  CaloriesWidgetsBundle.swift
//  Calories Widgets
//
//  Created by Radoslav Bley on 23/09/2026.
//

import SwiftUI
import WidgetKit

@main
struct CaloriesWidgetsBundle: WidgetBundle {
    var body: some Widget {
        CaloriesRingsWidgets()
        LaunchAppWidgetControl()
        LogCaloriesWidgetControl()
    }
}
