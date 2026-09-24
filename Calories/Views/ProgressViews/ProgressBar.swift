//
//  ProgressBar.swift
//  Calories
//
//  Created by Radoslav Bley on 23/09/2026.
//

import SwiftUI

struct ProgressBar: View {
    let value: Double
    let total: Double

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.accent.quinary)
            Capsule()
                .fill(LinearGradient(colors: [.accent, .accent.opacity(value == total ? 1 : 0.6)], startPoint: .leading, endPoint: .trailing))
                .shadow(color: .accent.opacity(0.4), radius: 4, y: 4)
                .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in
                    length * (value / total)
                }
        }
        .animation(.interactiveSpring, value: value)
    }
}

#Preview {
    ProgressBar(value: 430, total: 1500)
        .frame(height: 12)
}
