//
//  CustomStepper.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct CustomStepper: View {
    @Binding var value: Double
    let step: Double

    init(value: Binding<Double>, step: Double = 10) {
        self._value = value
        self.step = step
    }

    var body: some View {
        HStack(spacing: 20) {
            StepperButton {
                updateValue(.decrease)
            } label: {
                Circle()
                    .fill(.accent)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "minus")
                            .imageScale(.large)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
            }
            .disabled(value == 0)

            Text(value.formattedValue())
                .font(.system(size: 64))
                .fontDesign(.rounded)
                .contentTransition(.numericText(value: value))
                .frame(width: 200)

            StepperButton {
                updateValue(.increase)
            } label: {
                Circle()
                    .fill(.accent)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
            }
        }
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func updateValue(_ direction: StepperDirection) {
        withAnimation(.bouncy) {
            switch direction {
            case .decrease:
                value -= step
            case .increase:
                value += step
            }
        }
    }
}

#Preview {
    CustomStepper(value: .constant(0))
}
