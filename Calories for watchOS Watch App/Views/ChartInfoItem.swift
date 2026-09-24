//
//  ChartInfoItem.swift
//  Calories
//
//  Created by Radoslav Bley on 23/09/2026.
//

import SwiftUI

struct ChartInfoItem: View {
    let value: Double
    let secondaryValue: Double
    let tertiaryValue: Double

    @Environment(CaloriesViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 2) {
                Text("\(value.formattedValue())/")
                    .font(.title)
                VStack(alignment: .leading, spacing: -2) {
                    Text(secondaryValue.formattedValue())
                    Text(viewModel.unit.unitExtension.uppercased())
                        .font(.footnote)
                }
                .padding(.top, 2)
            }
            .fontWeight(.semibold)

            Text(tertiaryValue.formatted(.percent.precision(.fractionLength(0))))
                .foregroundStyle(Color.secondary)
                .fontWeight(.medium)
        }
    }
}
