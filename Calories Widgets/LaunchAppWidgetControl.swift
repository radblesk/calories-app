//
//  LaunchAppWidgetControl.swift
//  Calories Widgets
//
//  Created by Radoslav Bley on 23/09/2026.
//

import AppIntents
import SwiftUI
import WidgetKit

struct LaunchAppWidgetControl: ControlWidget {
    let kind: String = "com.radobley.Calories.Widgets"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: kind) {
            ControlWidgetButton("Launch App", action: LaunchAppIntent()) { _ in
                Image(systemName: "heart.gauge.open")
            }
        }
        .displayName("Launch App")
    }
}

struct LaunchAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Launch App"
    static var description: IntentDescription? = IntentDescription(
        "Launch Calories App",
        categoryName: "Health",
        searchKeywords: ["calories", "log", "diet", "dietary", "health"],
        resultValueName: "Calories"
    )
    static var supportedModes: IntentModes = .foreground

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
