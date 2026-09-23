//
//  Calories_for_watchOSApp.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

@main
struct Calories_for_watchOS_Watch_AppApp: App {

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
