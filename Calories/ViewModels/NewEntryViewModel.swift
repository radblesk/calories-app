//
//  NewEntryViewModel.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

@Observable
final class NewEntryViewModel {

    // Data

    var newValue: Double? = nil
    var newDate: Date = .now
    var items: [EnergyData] = [.init()] {
        didSet {
            countEnergy(for: items)
        }
    }

    // Interaction

    var confirmClose: Bool = false
    var presentingModal: Bool = false

    // Helpers

    @ObservationIgnored
    let unit = CaloriesViewModel.shared.unit

    var navigationTitle: Text {
        let value = newValue ?? 0
        let formattedValue = value.formatted(.number.precision(.fractionLength(2)))
        if value > 0 {
            return Text("\(formattedValue) \(unit.unitExtension)")
        } else {
            return Text("")
        }
    }

    var navigationSubtitle: Text {
        let value = newValue ?? 0
        if value > 0 {
            return Text("Total")
        } else {
            return Text("")
        }
    }

    // MARK: Methods

    private func countEnergy(for items: [EnergyData]) {
        let values = items.compactMap { item -> Double? in
            guard let value = item.value, let weight = item.weight else { return nil }
            return value * (weight / 100)
        }

        withAnimation {
            newValue = values.isEmpty ? nil : values.reduce(0, +)
        }
    }

    func addItem(_ proxy: ScrollViewProxy, focus: FocusState<FocusedField?>.Binding) {
        let item = EnergyData()
        withAnimation {
            items.append(item)
        } completion: {
            withAnimation {
                focus.wrappedValue = .value(item.id)
                proxy.scrollTo(item.id, anchor: .top)
            }
        }

    }

    func nextItem(_ proxy: ScrollViewProxy, focus: FocusState<FocusedField?>.Binding) {
        switch focus.wrappedValue {
        case .value(let uUID):
            focus.wrappedValue = .weight(uUID)
        case .weight(let uUID):
            guard let index = items.firstIndex(where: { $0.id == uUID }) else {
                break
            }

            if index < items.count - 1 {
                focus.wrappedValue = .value(items[index + 1].id)
            } else {
                addItem(proxy, focus: focus)
            }
        case nil:
            break
        }
    }

    func previousItem(_ proxy: ScrollViewProxy, focus: FocusState<FocusedField?>.Binding) {
        switch focus.wrappedValue {
        case .value(let uUID):
            guard let index = items.firstIndex(where: { $0.id == uUID }) else {
                break
            }
            if index > 0 {
                focus.wrappedValue = .weight(items[index - 1].id)
            }
        case .weight(let uUID):
            focus.wrappedValue = .value(uUID)
        case nil:
            break
        }
    }
}
