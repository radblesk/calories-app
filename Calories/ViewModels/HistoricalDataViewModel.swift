//
//  HistoricalDataViewModel.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

internal import HealthKit
import SwiftUI

@Observable
final class HistoricalDataViewModel {
    var data: [HKQuantitySample] = []

    func fetchRecords(for identifier: HKQuantityTypeIdentifier) async {
        let results = await HealthStoreClient.shared.fetchRecords(for: identifier)
        let bundleId = "com.radobley.Calories"
        let watchBundleId = bundleId + ".watchkitapp"
        data = results.filter({ sample in
            let sampleBundleId = sample.sourceRevision.source.bundleIdentifier
            return sampleBundleId == bundleId || sampleBundleId == watchBundleId
        })
    }

    func remove(at offsets: IndexSet) {
        Task {
            for offset in offsets {
                let item = data[offset]
                let bundleId = "com.radobley.Calories"
                let watchBundleId = bundleId + ".watchkitapp"
                let itemSourceBundleIdentifier = item.sourceRevision.source.bundleIdentifier
                guard bundleId == itemSourceBundleIdentifier || watchBundleId == itemSourceBundleIdentifier else { return }
                data.removeAll(where: { $0 == item })
                await HealthStoreClient.shared.deleteSample(item)
            }
        }
    }
}
