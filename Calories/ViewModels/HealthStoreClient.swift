//
//  HealthStoreClient.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import HealthKit
import SwiftUI

@Observable
class HealthStoreClient {
    static let shared = HealthStoreClient()
    private init() { initializeHealthStore() }

    @ObservationIgnored
    var healthStore: HKHealthStore? = nil

    // Availability

    var isUnavailable: Bool = false

    // MARK: - Helper Methods

    private func withAvailabilityCheck(_ operation: () -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            isUnavailable = false
            operation()
        } else {
            isUnavailable = true
        }
    }

    private func initializeHealthStore() {
        withAvailabilityCheck {
            self.healthStore = HKHealthStore()
        }
    }
}
