//
//  overlays.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

struct Overlays: ViewModifier {
    @Environment(HealthStoreClient.self) private var healthStoreClient

    func body(content: Content) -> some View {
        @Bindable var healthStoreClient = self.healthStoreClient
        content
            .alert(healthStoreClient.currentError?.title ?? "Unknown Error", item: $healthStoreClient.currentError) { error in
                Button(role: .close) {
                    healthStoreClient.errorQueue.removeLast()
                }
            } message: { error in
                if let error = error.error {
                    Text(error.localizedDescription)
                }
            }

    }
}

extension View {
    func overlays() -> some View {
        modifier(Overlays())
    }
}
