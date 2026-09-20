//
//  environments.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

struct Environments: ViewModifier {
    @State private var healthStoreClient = HealthStoreClient.shared

    func body(content: Content) -> some View {
        content
            .environment(healthStoreClient)
    }
}

extension View {
    func environments() -> some View {
        modifier(Environments())
    }
}
