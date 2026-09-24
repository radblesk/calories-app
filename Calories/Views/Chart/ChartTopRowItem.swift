//
//  ChartTopRowItem.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct ChartTopRowItem: View {
    let title: String
    let value: Double

    @Environment(CaloriesViewModel.self) private var viewModel

    var attributedValue: AttributedString {
        let value = AttributedString(value.formatted(.number.precision(.fractionLength(0))))
        var unit = AttributedString(viewModel.unit.unitExtension)
        unit.foregroundColor = .gray
        return value + " " + unit
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.gray)
            Text(attributedValue)
                .contentTransition(.numericText(value: value))
        }
        .fontWeight(.medium)
        .animation(.default, value: value)
    }
}
