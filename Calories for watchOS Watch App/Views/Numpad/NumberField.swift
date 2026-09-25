//
//  NumberField.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct NumberField<Label: View>: View {
    let placeholder: String?
    @Binding var value: Double?

    init(_ placeholder: String?, value: Binding<Double?>, @ContentBuilder label: () -> Label) {
        self.placeholder = placeholder
        self._value = value
        self.label = label()
    }

    init(_ placeholder: String?, value: Binding<Double>, @ContentBuilder label: () -> Label) {
        self.placeholder = placeholder
        self._value = Binding(
            get: { value.wrappedValue },
            set: { newValue in
                if let newValue {
                    value.wrappedValue = newValue
                }
            }
        )
        self.label = label()
    }

    init(_ placeholder: String?, value: Binding<Double?>) where Label == EmptyView {
        self.placeholder = placeholder
        self._value = value
        self.label = EmptyView()
    }

    init(_ placeholder: String?, value: Binding<Double>) where Label == EmptyView {
        self.placeholder = placeholder
        self._value = Binding(
            get: { value.wrappedValue },
            set: { newValue in
                if let newValue {
                    value.wrappedValue = newValue
                }
            }
        )
        self.label = EmptyView()
    }

    let label: Label

    @State private var presentingInput: Bool = false

    private var presentationLabel: String {
        if let value, !hideValue {
            return "\(value)"
        } else if let placeholder {
            return placeholder
        }
        return ""
    }

    var body: some View {
        Button {
            presentingInput.toggle()
        } label: {
            if Label.self != EmptyView.self {
                label
            } else {
                Text(presentationLabel)
                    .foregroundStyle(value == nil ? .tertiary : .primary)
            }
        }
        .fullScreenCover(isPresented: $presentingInput) {
            NavigationStack {
                NumberInputView(placeholder: placeholder, value: $value, style: numpadStyle)
            }
        }
    }

    private var numpadStyle: NumpadStyle = .decimal
    private var hideValue: Bool = false

    func numpadStyle(_ style: NumpadStyle) -> Self {
        var copy = self
        copy.numpadStyle = style
        return copy
    }

    func hideValue(_ enabled: Bool = true) -> Self {
        var copy = self
        copy.hideValue = enabled
        return copy
    }
}
