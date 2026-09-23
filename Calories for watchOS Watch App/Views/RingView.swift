//
//  RingView.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct RingView: View {
    let progress: CGFloat
    let color: Color
    let level: Int
    let symbol: String?

    let lineWidth: CGFloat = 20

    var padding: CGFloat {
        if level > 1 {
            return lineWidth * CGFloat(level - 1) + 2
        }

        return 0
    }

    @State private var currentProgress: Double = 0
    @State private var size: CGSize = .zero
    @State private var displayCap: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
                .animation(.none, value: currentProgress)

            Circle()
                .trim(from: 0, to: currentProgress)
                .stroke(
                    AngularGradient(colors: [color, color.exposureAdjust(-1.4)], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(color)
                .background {
                    Circle()
                        .fill(.black.quaternary)
                        .blur(radius: 4)
                        .offset(x: -lineWidth / 4)
                        .mask {
                            Rectangle()
                                .offset(x: -lineWidth / 2)
                        }
                }
                .scaleEffect(displayCap ? 1 : 0.75)
                .opacity(displayCap ? 1 : 0)
                .overlay {
                    if let symbol {
                        Image(systemName: symbol)
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                            .fontWeight(.light)
                            .foregroundStyle(.black)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                }
                .frame(width: lineWidth, height: lineWidth)
                .offset(y: -1 * (size.height / 2))
        }
        .rotationEffect(overlapRotation())
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .onGeometryChange(
            for: CGSize.self,
            of: { geo in
                geo.size
            },
            action: { newValue in
                size = newValue
            }
        )
        .padding(padding)
        .task(id: progress) {
            try? await Task.sleep(for: .milliseconds(500))

            if progress > 0 {
                withAnimation {
                    displayCap = true
                }
            }

            try? await Task.sleep(for: .milliseconds(500))

            withAnimation(.spring(duration: max(currentProgress / 2, 5), blendDuration: 0.5), completionCriteria: .removed) {
                currentProgress = progress
            } completion: {
                withAnimation {
                    displayCap = progress > 0
                }
            }

        }
    }

    func overlapRotation() -> Angle {
        let overlapProgress = currentProgress - 1.0
        let degrees = overlapProgress * 360.0
        return .degrees(-1 * degrees)
    }
}

#Preview {
    ContentView()
        .environments()
}

#Preview {
    @Previewable @State var progress: Double = 0
    ZStack {
        RingView(progress: progress, color: .cyan, level: 1, symbol: "fork.knife")
        RingView(progress: progress / 3, color: .pink, level: 2, symbol: "pizza.slice")
            .task {
                progress = 1.2
                try? await Task.sleep(for: .seconds(5))
                progress = 0
            }
    }
}
