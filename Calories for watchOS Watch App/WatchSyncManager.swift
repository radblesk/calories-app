//
//  WatchSyncManager.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import WatchConnectivity

final class WatchSyncManager: NSObject, WCSessionDelegate {

    static let shared = WatchSyncManager()

    private override init() {
        super.init()

        guard WCSession.isSupported() else { return }

        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func syncDailyLimit(_ value: Double) {
        updateApplicationContext(key: "dailyLimit", value: value)
    }

    func syncUnit(_ value: Unit) {
        updateApplicationContext(key: "unit", value: value.rawValue)
    }

    private func updateApplicationContext(key: String, value: Any) {
        let session = WCSession.default

        guard session.activationState == .activated else {
            return
        }

        var context = session.applicationContext
        context[key] = value

        do {
            try session.updateApplicationContext(context)
        } catch {
            print("Watch sync error:", error)
        }
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        let dailyLimit = applicationContext["dailyLimit"] as? Double
        let unit = (applicationContext["unit"] as? String).flatMap(Unit.init(rawValue:))

        DispatchQueue.main.async {
            CaloriesViewModel.shared.applyRemoteSettings(dailyLimit: dailyLimit, unit: unit)
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("WCSession activation error:", error)
            return
        }

        if activationState == .activated {
            syncDailyLimit(CaloriesViewModel.shared.calorieLimit)
            syncUnit(CaloriesViewModel.shared.unit)
        }
    }

    #if os(iOS)

        func sessionDidBecomeInactive(_ session: WCSession) {}

        func sessionDidDeactivate(_ session: WCSession) {
            session.activate()
        }

    #endif
}
