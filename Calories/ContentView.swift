//
//  ContentView.swift
//  Calories
//
//  Created by Radoslav Bley on 20/09/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SummaryView()
            .overlays()
    }
}

#Preview {
    ContentView()
        .overlays()
        .environments()
}
