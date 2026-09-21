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
        data = results.filter({ sample in
            return sample.sourceRevision.source.bundleIdentifier == Bundle.main.bundleIdentifier
        })
    }

    func remove(at offsets: IndexSet) {
        Task {
            for offset in offsets {
                let item = data[offset]
                let appBundleIdentifier = Bundle.main.bundleIdentifier
                let itemSourceBundleIdentifier = item.sourceRevision.source.bundleIdentifier
                guard appBundleIdentifier == itemSourceBundleIdentifier else { return }
                data.removeAll(where: { $0 == item })
                await HealthStoreClient.shared.deleteSample(item)
            }
        }
    }
}
