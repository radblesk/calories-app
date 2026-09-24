//
//  StepperButton.swift
//  Calories
//
//  Created by Radoslav Bley on 24/09/2026.
//

import SwiftUI

struct StepperButton<Label: View>: View {
    let action: () -> Void
    @ContentBuilder let label: () -> Label

    let generator = UIImpactFeedbackGenerator()
    @State private var task: Task<Void, Never>?

    var body: some View {
        label()
            .contentShape(.rect)
            .onLongPressGesture(minimumDuration: .infinity) {

            } onPressingChanged: { isPressing in
                if isPressing {
                    action()
                    generator.impactOccurred()
                    startRepeating()
                } else {
                    task?.cancel()
                    task = nil
                }
            }
            .opacity(task != nil ? 0.7 : 1)
            .scaleEffect(task != nil ? 0.95 : 1)
            .animation(.bouncy, value: task)
    }

    private func startRepeating() {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: .milliseconds(400))

            var delay = 200.0

            while !Task.isCancelled {
                action()
                generator.impactOccurred()
                try? await Task.sleep(for: .milliseconds(delay))
                delay = max(35, delay * 0.9)
            }
        }
    }
}
