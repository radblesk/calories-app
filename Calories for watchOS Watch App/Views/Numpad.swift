//
//  Numpad.swift
//  Calories for watchOS Watch App
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct Numpad: View {
    @Binding var stringValue: String
    let style: NumpadStyle

    var body: some View {
        Grid {
            GridRow {
                Button("1") {
                    withAnimation {
                        stringValue.append("1")
                    }
                }
                Button("2") {
                    withAnimation {
                        stringValue.append("2")
                    }
                }
                Button("3") {
                    withAnimation {
                        stringValue.append("3")
                    }
                }
            }
            .disabled(stringValue.hasPrefix("0") && !stringValue.contains("."))

            GridRow {
                Button("4") {
                    withAnimation {
                        stringValue.append("4")
                    }
                }
                Button("5") {
                    withAnimation {
                        stringValue.append("5")
                    }
                }
                Button("6") {
                    withAnimation {
                        stringValue.append("6")
                    }
                }
            }
            .disabled(stringValue.hasPrefix("0") && !stringValue.contains("."))

            GridRow {
                Button("7") {
                    withAnimation {
                        stringValue.append("7")
                    }
                }
                Button("8") {
                    withAnimation {
                        stringValue.append("8")
                    }
                }
                Button("9") {
                    withAnimation {
                        stringValue.append("9")
                    }
                }
            }
            .disabled(stringValue.hasPrefix("0") && !stringValue.contains("."))

            GridRow {
                if style == .decimal {
                    Button(".") {
                        withAnimation {
                            stringValue.append(".")
                        }
                    }
                    .disabled(stringValue.count == 0 || stringValue.contains("."))
                    .frame(maxWidth: 55)
                    .gridCellAnchor(.trailing)
                } else {
                    Color.clear
                }

                Button("0") {
                    withAnimation {
                        stringValue.append("0")
                    }
                }
                .disabled((stringValue.hasPrefix("0") && !stringValue.contains(".")) || (style == .number && stringValue.isEmpty))

                Button("Backspace", systemImage: "delete.left") {
                    withAnimation {
                        stringValue.removeLast(1)
                    }
                }
                .disabled(stringValue.isEmpty)
                .frame(maxWidth: 55)
                .buttonStyle(.numpadProminent)
                .labelStyle(.iconOnly)
                .gridCellAnchor(.leading)
            }
            .gridCellUnsizedAxes(.vertical)
        }
        .font(.title3)
        .buttonStyle(.numpad)
        .padding(.bottom, 12)
        .controlSize(.small)
        .buttonStyle(.bordered)
    }
}

struct NumpadButtonStyle: ButtonStyle {
    let isProminent: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
        }
        .frame(maxWidth: .infinity, maxHeight: 14)
        .padding()
        .background(configuration.isPressed ? .quaternary : isProminent ? .secondary : .tertiary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

extension ButtonStyle where Self == NumpadButtonStyle {
    static var numpad: NumpadButtonStyle { .init(isProminent: false) }
}

extension ButtonStyle where Self == NumpadButtonStyle {
    static var numpadProminent: NumpadButtonStyle { .init(isProminent: true) }
}

#Preview {
    NavigationStack {
        NumberInputView(placeholder: "something", value: .constant(24.5), style: .decimal)
            .overlay(alignment: .top) {
                HStack(alignment: .top) {
                    Button("", systemImage: "xmark") {}
                    Text("23:00")
                    Button("", systemImage: "checkmark") {}
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.mini)
                .padding(.top, 10)
                .ignoresSafeArea()
            }
    }
}
