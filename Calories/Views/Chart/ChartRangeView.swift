//
//  ChartRangeView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct ChartRangeView<Content: View>: View {
    let content: Content

    init(@ContentBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 0) {
            Group(subviews: content) { collection in
                ForEach(collection) { view in
                    if view.id == collection.last?.id {
                        Text(", ")
                    }
                    view

                    if view.id == collection.first?.id {
                        Text(" – ")
                    }
                }
            }
        }
        .foregroundStyle(.gray)
        .font(.footnote)
        .fontWeight(.medium)
    }
}
