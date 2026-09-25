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
            isAvailable = true
            authorizationRequested = UserDefaults.standard.bool(forKey: "authorizationRequested")
        } else {
            errorQueue.append(HealthStoreClientError(title: "HealthKit is not available", error: nil))
            isAvailable = false
        }
    }

    @ObservationIgnored
    var healthStore: HKHealthStore?

    @ObservationIgnored
    private var authorizationTask: Task<Void, Error>?

    // Availability

    var isAvailable: Bool = false
    var authorizationRequested: Bool = false {
        didSet {
            UserDefaults.standard.set(authorizationRequested, forKey: "authorizationRequested")
        }
    }

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

    func requestAuthorizationIfNeeded() async {
        guard !authorizationRequested else { return }
        let readTypes: Set = [
            HKQuantityType(.dietaryEnergyConsumed)
        ]
        let shareTypes: Set = [
            HKQuantityType(.dietaryEnergyConsumed)
        ]
        do {
            let status = try await healthStore?.statusForAuthorizationRequest(toShare: shareTypes, read: readTypes)

            switch status {
            case .shouldRequest:
                try await healthStore?.requestAuthorization(toShare: shareTypes, read: readTypes)
                authorizationRequested = true
            default: break
            }
        } catch {
            print("Authorization Request Failed")
        }
    }

    func fetchStatistics(for identifier: HKQuantityTypeIdentifier, from startDate: Date, to endDate: Date?, interval: DateComponents)
        -> AsyncThrowingStream<HKStatisticsCollection?, Error>
    {
        guard isAvailable, let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return AsyncThrowingStream { continuation in
                continuation.yield(nil)
                continuation.finish()
            }
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let store = self.healthStore
        return AsyncThrowingStream { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: endOfDay,
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, statistics, error in
                if let error {
                    continuation.finish(throwing: error)
                } else {
                    continuation.yield(statistics)
                }
            }
            query.statisticsUpdateHandler = { _, _, statistics, error in
                if let error {
                    continuation.finish(throwing: error)
                } else {
                    continuation.yield(statistics)
                }
            }

            continuation.onTermination = { @Sendable _ in
                store?.stop(query)
            }
            store?.execute(query)
        }
    }

    func fetchRecords(for identifier: HKQuantityTypeIdentifier) async -> [HKQuantitySample] {
        guard isAvailable, let sampleType = HKObjectType.quantityType(forIdentifier: identifier), let healthStore else { return [] }
        let predicate = HKSamplePredicate.quantitySample(type: sampleType)
        let sortDescriptor = SortDescriptor<HKQuantitySample>(\.endDate, order: .reverse)
        let descriptor = HKSampleQueryDescriptor(predicates: [predicate], sortDescriptors: [sortDescriptor])

        do {
            return try await descriptor.result(for: healthStore)
        } catch {
            errorQueue.append(HealthStoreClientError(title: "Failed to Query Sample Data", error: error))
            return []
        }
    }

    func saveSample(for identifier: HKQuantityTypeIdentifier, count: Double, at date: Date) async {
        guard isAvailable, let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { return }

        let unit = CaloriesViewModel.shared.unit
        let quantity = HKQuantity(unit: unit.hkUnit, doubleValue: count)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)

        do {
            try await healthStore?.save(sample)
            confirmation = HealthStoreClientConfirmation(title: "Data saved", message: nil)
        } catch {
            errorQueue.append(HealthStoreClientError(title: "Failed to save data", error: error))
        }
    }

    func deleteSample(_ sample: HKQuantitySample) async {
        guard isAvailable else { return }
        do {
            try await healthStore?.delete(sample)
        } catch {
            errorQueue.append(HealthStoreClientError(title: "Failed to delete data", error: error))
        }
    }
}
