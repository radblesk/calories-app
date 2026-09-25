//
//  SemicircleProgressView.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI
import WidgetKit

struct SemicircleProgressView: View {
    let value: Double
    let total: Double?
    let color: Color

    private var secondaryValue: Double? = nil
    private var secondaryColor: Color = .accent
    private var isWidget: Bool = false

    init(value: Double, total: Double? = nil, color: Color = .accent) {
        self.value = value
        self.total = total
        self.color = color
    }

    @State private var currentProgress: Double = 0
    @State private var secondaryProgress: Double = 0
    @State private var size: CGFloat = .zero

    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        VStack(spacing: -(size * 0.12)) {
            ZStack(alignment: .bottom) {
                Semicircle(secondary: secondaryValue != nil)
                    .stroke(color.quinary, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                    .widgetAccentable()

                Semicircle(secondary: secondaryValue != nil)
                    .trim(from: 0, to: currentProgress)
                    .stroke(color.gradient, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                    .shadow(color: color.opacity(0.4), radius: size * 0.02, y: size * 0.02)
                    .widgetAccentable(isWidget)

                if total != nil {
                    Text(value > 0 ? value.formattedValue() : "--")
                        .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                        .offset(y: size * 0.12)
                        .contentTransition(.numericText(value: value))
                        .animation(.bouncy, value: value)
                        .privacySensitive(isWidget)
                }
            }
            .padding(.bottom, size * 0.12)

            if secondaryValue != nil {
                ZStack {
                    Semicircle(secondary: true)
                        .stroke(secondaryColor.quinary, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                        .widgetAccentable()

                    Semicircle(secondary: true)
                        .trim(from: 0, to: secondaryProgress)
                        .stroke(secondaryColor.gradient, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                        .shadow(color: secondaryColor.opacity(0.4), radius: size * 0.02, y: size * 0.02)
                        .widgetAccentable()
                }
                .rotationEffect(.degrees(180))
            }
        }
        .padding(.bottom, secondaryValue != nil ? -size * 0.12 : 0)
        .aspectRatio(secondaryValue != nil ? 1 : 16 / 10, contentMode: .fit)
        .task(id: value) {
            if isWidget && redactionReasons == .privacy {
                return
            }

            withAnimation(.interactiveSpring(duration: 1.2)) {
                currentProgress = max(min(value / (total ?? 1), 1), 0)
                if let secondaryValue {
                    secondaryProgress = max(min(secondaryValue / (total ?? 1), 1), 0)
                }
            }
        }
        .onGeometryChange(for: CGFloat.self) { geo in
            geo.size.width
        } action: { newValue in
            size = newValue
        }

    }

    func secondaryValue(_ value: Double?, color: Color) -> Self {
        var copy = self
        copy.secondaryValue = value
        copy.secondaryColor = color
        return copy
    }

    func isWidget(_ enabled: Bool = true) -> Self {
        var copy = self
        copy.isWidget = enabled
        return copy
    }
}

#Preview {
    VStack {
        SemicircleProgressView(value: 1540, total: 1500)
            .secondaryValue(345, color: .orange)
            .frame(maxWidth: 300)
            .border(.red)
    }
}
