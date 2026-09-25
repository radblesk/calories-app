//
//  WatchSyncManager.swift
//  Calories
//
//  Created by Radoslav Bley on 25/09/2026.
//

import WatchConnectivity

final class WatchSyncManager: NSObject, WCSessionDelegate {
    static let shared = WatchSyncManager()

    private var session = WCSession.default

    private override init() {
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            print("WCSession activation error:", error)
            return
        }

        if activationState == .activated {
            //
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let rawUnit = applicationContext["unit"] as? String,
            let unit = Unit(rawValue: rawUnit),
            let limit = applicationContext["limit"] as? Double,
            let modifiedAt = applicationContext["modifiedAt"] as? Double
        else { return }

        DispatchQueue.main.async {
            CaloriesViewModel.shared.applyRemoteSettings(unit: unit, limit: limit, modifiedAt: modifiedAt)
        }
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {
            //
        }

        func sessionDidDeactivate(_ session: WCSession) {
            //
        }
    #endif

    // MARK: - Methods

    func syncSettings(unit: Unit, limit: Double, modifiedAt: Double) {
        let context: [String: Any] = [
            "unit": unit.rawValue,
            "limit": limit,
            "modifiedAt": modifiedAt,
        ]

        withCheckedAvailability {
            try session.updateApplicationContext(context)
        }
    }

    // MARK: - Helper Methods

    private func withCheckedAvailability(_ operation: () throws -> Void) {
        guard session.activationState == .activated else { return }
        #if os(iOS)
            guard session.isPaired, session.isWatchAppInstalled else { return }
        #endif

        do {
            try operation()
        } catch {
            print("Error updating application context")
        }
    }
}
