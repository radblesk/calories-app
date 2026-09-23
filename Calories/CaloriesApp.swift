//
//  CaloriesApp.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

@main
struct CaloriesApp: App {

    init() {
        _ = WatchSyncManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environments()
                .fontDesign(.rounded)
        }
    }
}
