//
//  StatisticsRowView.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct StatisticsRowView: View {
    let title: String
    let value: Double

    @Environment(CaloriesViewModel.self) private var viewModel

    var attributedValue: AttributedString {
        var suffix = AttributedString(viewModel.unit.unitExtension)
        suffix.foregroundColor = .secondary
        let value = AttributedString(value.formatted(.number.precision(.fractionLength(fractionLength))))
        return value + " " + suffix
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(.secondary)

            Text(attributedValue)
                .font(.title2)
        }
        .fontWeight(.medium)
    }

    private var fractionLength: Int = 0

    func fractionLength(_ length: Int) -> Self {
        var copy = self
        copy.fractionLength = length
        return copy
    }
}

#Preview {
    StatisticsRowView(title: "Title", value: 200)
}
