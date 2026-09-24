//
//  SemicircleProgressView.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct SemicircleProgressView: View {
    let progress: Double
    let lineWidth: Double

    init(progress: Double, lineWidth: Double = 27) {
        self.progress = progress
        self.lineWidth = lineWidth
    }

    @State private var currentProgress: Double = 0

    var body: some View {
        ZStack {
            Semicircle()
                .stroke(.accent.quinary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

            Semicircle()
                .trim(from: 0, to: currentProgress)
                .stroke(.accent.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .shadow(color: .accent.opacity(0.4), radius: 6, y: 6)
        }
        .animation(.interactiveSpring(duration: 1.2), value: currentProgress)
        .task(id: progress) {
            currentProgress = max(min(progress, 1), 0)
        }
    }
}

struct Semicircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width / 2, rect.height)

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )

        return path
    }
}

#Preview {
    VStack {
        SemicircleProgressView(progress: 0.5)
            .frame(maxWidth: 300)
    }
}
