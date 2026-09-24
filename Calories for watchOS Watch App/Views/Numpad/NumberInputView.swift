//
//  NumberInputView.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct NumberInputView: View {
    let placeholder: String?
    @Binding var value: Double?
    let style: NumpadStyle

    @State private var stringValue: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var hadInitialValue: Bool = false

    init(placeholder: String?, value: Binding<Double?>, style: NumpadStyle) {
        self.placeholder = placeholder
        self._value = value
        self.style = style
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack {
                if stringValue.isEmpty, let placeholder {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                }

                Text(stringValue)
                    .font(.title2)
                    .animation(.none, value: stringValue)
            }
            .lineLimit(1, reservesSpace: true)
            .frame(minHeight: 20, maxHeight: 25)

            Numpad(stringValue: $stringValue, style: style)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(.black)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    if !hadInitialValue { value = nil }
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm", systemImage: "checkmark", role: .confirm) {
                    dismiss()
                }
                .disabled(value == nil)
            }
        }
        .onChange(of: stringValue) { _, newValue in
            value = Double(newValue)
        }
        .onAppear {
            if let value {
                stringValue = "\(value)"
                hadInitialValue = true
            }
        }
    }
}
