//
//  SharedStorage.swift
//  Calories
//
//  Created by Radoslav Bley on 25/09/2026.
//

import Foundation

enum SharedStorage {
    static let defaults = UserDefaults(suiteName: "group.com.radobley.Calories") ?? UserDefaults.standard
}
