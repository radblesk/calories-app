//
//  Ring.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct Ring: View {
    let progress: CGFloat
    let level: Int

    private var lineWidth: CGFloat = 20
    private var color: Color {
        switch level {
        case 1: .pink
        case 2: .yellow
        default: .green
        }
    }

    private var showSymbol: Bool = false
    private var symbol: String {
        switch level {
        case 1: "fork.knife"
        case 2: "chevron.right.dotted.chevron.right"
        case 3: "scalemass"
        default: ""
        }
    }

    var padding: CGFloat {
        let spacing: CGFloat = isWidget ? 1 : 2
        if level > 1 {
            return (lineWidth + spacing) * CGFloat(level - 1)
        }

        return 0
    }

    @State private var currentProgress: Double = 0
    @State private var size: CGSize = .zero
    @State private var displayCap: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
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
                        .fill(.black.quinary)
                        .blur(radius: 2)
                        .offset(x: -lineWidth / 6)
                        .mask {
                            Rectangle()
                                .offset(x: -lineWidth / 2)
                        }
                }
                .scaleEffect(displayCap ? 1 : 0.75)
                .opacity(displayCap ? 1 : 0)
                .overlay {
                    if showSymbol {
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
            guard !isWidget else {
                displayCap = progress > 0
                currentProgress = progress
                return
            }

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

    private var isWidget: Bool = false

    func isWidget(_ enabled: Bool = true) -> Self {
        var copy = self
        copy.isWidget = enabled
        return copy
    }

    func lineWidth(_ width: CGFloat) -> Self {
        var copy = self
        copy.lineWidth = width
        return copy
    }

    func showSymbol(_ enabled: Bool = true) -> Self {
        var copy = self
        copy.showSymbol = enabled
        return copy
    }
}

#Preview {
    @Previewable @State var progress: Double = 0
    ZStack {
        Ring(progress: progress, level: 1)
            .showSymbol()
        Ring(progress: progress / 3, level: 2)
            .showSymbol()
        Ring(progress: progress / 4, level: 3)
            .showSymbol()
            .task {
                progress = 1.2
                //                try? await Task.sleep(for: .seconds(5))
                //                progress = 0
            }
    }
}
