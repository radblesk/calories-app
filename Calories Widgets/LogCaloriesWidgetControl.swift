//
//  LogCaloriesWidgetControl.swift
//  Calories
//
//  Created by Radoslav Bley on 23/09/2026.
//

import AppIntents
import SwiftUI
import WidgetKit

struct LogCaloriesWidgetControl: ControlWidget {
    let kind: String = "com.radobley.Calories.Log"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: kind) {
            ControlWidgetButton("Log Calories", action: LogCaloriesIntent()) { _ in
                Image(systemName: "fork.knife")
            }
        }
        .displayName("Log Calories")
        .description("Create new entry in Apple Health")
    }
}

struct LogCaloriesIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Calories"
    static let description: IntentDescription? = IntentDescription(
        "Log Calories to Apple Health",
        categoryName: "Health",
        searchKeywords: ["log", "calories", "health", "diet", "dietary"],
        resultValueName: "Calories"
    )

    static let supportedModes: IntentModes = .foreground

    @MainActor
    func perform() async throws -> some IntentResult {
        CaloriesViewModel.shared.addingData = true
        return .result()
    }
}

struct LogCaloriesAppShortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogCaloriesIntent(),
            phrases: [
                "Log Calories in \(.applicationName)",
                "Log Calories using \(.applicationName) app",
            ],
            shortTitle: "Log Calories",
            systemImageName: "fork.knife"
        )
    }
}
