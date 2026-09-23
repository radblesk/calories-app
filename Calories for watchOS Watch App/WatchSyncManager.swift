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
        if let dailyLimit = applicationContext["dailyLimit"] as? Double {
            DispatchQueue.main.async {
                UserDefaults.standard.set(dailyLimit, forKey: "dailyLimit")
            }
        }
        if let unit = applicationContext["unit"] as? String {
            DispatchQueue.main.async {
                UserDefaults.standard.set(unit, forKey: "unit")
            }
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("WCSession activation error:", error)
        }
    }

    #if os(iOS)

        func sessionDidBecomeInactive(_ session: WCSession) {}

        func sessionDidDeactivate(_ session: WCSession) {
            session.activate()
        }

    #endif
}
