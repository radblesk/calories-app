//
//  AdaptiveView.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct AdaptiveView<PrimaryView, SecondaryView>: View where PrimaryView: View, SecondaryView: View {
    @ContentBuilder let primary: () -> PrimaryView
    @ContentBuilder let secondary: () -> SecondaryView

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass != .regular {
            primary()
        } else {
            secondary()
        }
    }
}

#Preview {
    AdaptiveView {
        Text("Primary View")
    } secondary: {
        Text("Secondary View")
    }
}
