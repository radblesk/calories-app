//
//  HealthStoreClient.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

internal import HealthKit
import SwiftUI

@Observable
final class HealthStoreClient {
    static let shared = HealthStoreClient()
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            isUnavailable = false
        } else {
            errorQueue.append(HealthStoreClientError(title: "HealthKit is not available", error: nil))
            isUnavailable = true
        }
    }

    @ObservationIgnored
    var healthStore: HKHealthStore?

    @ObservationIgnored
    private var hasRequestedAuthorization = false

    @ObservationIgnored
    private var authorizationTask: Task<Void, Error>?

    // Data

    var consumedToday: HKStatistics? = nil

    // Availability

    var isUnavailable: Bool = false

    // Error Handling
    var errorQueue: [HealthStoreClientError] = [] {
        didSet {
            currentError = errorQueue.last
        }
    }
    var currentError: HealthStoreClientError?

    // Confirmation
    var confirmation: HealthStoreClientConfirmation?

    // MARK: - Helper Methods

    private func withAvailabilityCheck(_ operation: () async -> Void) async {
        if HKHealthStore.isHealthDataAvailable() {
            isUnavailable = false
            await operation()
        } else {
            isUnavailable = true
        }
    }

    private func requestAuthorizationIfNeeded() async throws {
        guard !hasRequestedAuthorization else { return }
        if let authorizationTask {
            try await authorizationTask.value
            return
        }
        guard let healthStore else { return }
        guard let dietaryEnergy = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) else { return }

        let task = Task {
            try await healthStore.requestAuthorization(
                toShare: Set([dietaryEnergy]),
                read: Set([dietaryEnergy])
            )
        }
        authorizationTask = task

        do {
            try await task.value
            hasRequestedAuthorization = true
            authorizationTask = nil
        } catch {
            authorizationTask = nil
            throw error
        }
    }

    func fetchStatistics(for identifier: HKQuantityTypeIdentifier, from startDate: Date, to endDate: Date?) async -> HKStatisticsCollection? {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { return nil }

        let daily = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)

        do {
            try await requestAuthorizationIfNeeded()
            return try await withCheckedThrowingContinuation { continuation in
                let query = HKStatisticsCollectionQuery(
                    quantityType: quantityType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum,
                    anchorDate: .now,
                    intervalComponents: daily
                )
                query.initialResultsHandler = { _, statistics, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: statistics)
                    }
                }
                healthStore?.execute(query)
            }
        } catch {
            errorQueue.append(HealthStoreClientError(title: "Failed to read data", error: error))
            return nil
        }
    }

    func saveSample(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, count: Double, at date: Date) async {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { return }

        let quantity = HKQuantity(unit: unit, doubleValue: count)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)

        do {
            try await requestAuthorizationIfNeeded()
            try await healthStore?.save(sample)
            confirmation = HealthStoreClientConfirmation(title: "Data saved", message: nil)
        } catch {
            errorQueue.append(HealthStoreClientError(title: "Failed to save data", error: error))
        }
    }
}
