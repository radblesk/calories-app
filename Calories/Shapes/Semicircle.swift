//
//  Semicircle.swift
//  Calories
//
//  Created by Radoslav Bley on 25/09/2026.
//

import SwiftUI

struct Semicircle: Shape {
    let secondary: Bool

    init(secondary: Bool = false) {
        self.secondary = secondary
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width / 2.25, rect.height)

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: radius,
            startAngle: .degrees(secondary ? 190 : 200),
            endAngle: .degrees(secondary ? -10 : -20),
            clockwise: false
        )

        return path
    }
}

#Preview {
    SemicircleProgressView(value: 0.3, total: 1)
}
