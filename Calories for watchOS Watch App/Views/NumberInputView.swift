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

struct NumberField<Label: View>: View {
    let placeholder: String?
    @Binding var value: Double?

    init(_ placeholder: String?, value: Binding<Double?>, @ContentBuilder label: () -> Label) {
        self.placeholder = placeholder
        self._value = value
        self.label = label()
        self.presentingInput = isFocused
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
        self.presentingInput = isFocused
    }

    init(_ placeholder: String?, value: Binding<Double?>) where Label == EmptyView {
        self.placeholder = placeholder
        self._value = value
        self.label = EmptyView()
        self.presentingInput = isFocused
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
        self.presentingInput = isFocused
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
            if value != nil {
                onNumberSubmit()
            }
        } content: {
            NavigationStack {
                NumberInputView(placeholder: placeholder, value: $value, style: numpadStyle)
            }
        }
    }

    private var numpadStyle: NumpadStyle = .decimal
    private var onNumberSubmit: () -> Void = {}
    private var isFocused: Bool = false
    private var hideValue: Bool = false

    func numpadStyle(_ style: NumpadStyle) -> Self {
        var copy = self
        copy.numpadStyle = style
        return copy
    }

    func onNumberSubmit(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onNumberSubmit = action
        return copy
    }

    func isFocused<Value>(_ binding: FocusState<Value>.Binding, equals value: Value) -> Self where Value: Hashable {
        print(binding.wrappedValue)
        self.presentingInput = binding.wrappedValue == value
        return self
    }

    func isFocused(_ binding: FocusState<Bool>.Binding) -> Self {
        print(binding.wrappedValue)
        self.presentingInput = binding.wrappedValue
        return self
    }

    func hideValue(_ enabled: Bool = true) -> Self {
        var copy = self
        copy.hideValue = enabled
        return copy
    }
}

#Preview {
    NavigationStack {
        NumberInputView(placeholder: "something", value: .constant(24.5), style: .decimal)
    }
}
