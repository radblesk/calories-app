//
//  NewEntryView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct NewEntryView: View {
    @Environment(CaloriesViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("unit") private var unit: Unit = .kcal

    @State private var newValue: Double? = nil
    @State private var items: [EnergyData] = [.init()]
    @State private var newDate: Date = .now
    @FocusState private var isFocused: FocusedField?

    @State private var confirmClose: Bool = false

    enum FocusedField: Hashable {
        case value(UUID)
        case weight(UUID)
    }

    private var navigationTitle: Text {
        let value = newValue ?? 0
        let formattedValue = value.formatted(.number.precision(.fractionLength(2)))
        if value > 0 {
            return Text("\(formattedValue) \(unit.unitExtension)")
        } else {
            return Text("")
        }
    }

    private var navigationSubtitle: Text {
        let value = newValue ?? 0
        if value > 0 {
            return Text("Total")
        } else {
            return Text("")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    Section {
                        VStack {
                            Image(systemName: "pizza.slice")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color(.systemGray5))
                                .clipShape(.circle)
                                .foregroundStyle(.green)
                                .symbolRenderingMode(.hierarchical)

                            Text("Dietary Energy")
                                .font(.title)
                                .fontWeight(.bold)

                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color(.systemGroupedBackground))
                    .listSectionMargins(.top, 0)
                    .listRowInsets(.all, 0)
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)

                    LabeledContent {
                        DatePicker("", selection: $newDate, displayedComponents: .date)
                    } label: {
                        Text("Date")
                            .foregroundStyle(.gray)
                    }

                    LabeledContent {
                        DatePicker("", selection: $newDate, displayedComponents: .hourAndMinute)
                    } label: {
                        Text("Time")
                            .foregroundStyle(.gray)
                    }

                    //                    if let newValue {
                    //                        LabeledContent {
                    //                            Text("\(newValue.formatted(.number.precision(.fractionLength(2)))) \(unit.unitExtension)")
                    //                                .contentTransition(.numericText(value: newValue))
                    //                        } label: {
                    //                            Text("Total")
                    //                                .foregroundStyle(.gray)
                    //                        }
                    //                    }

                    ForEach($items.enumerated(), id: \.element.id) { index, $item in
                        Section {
                            LabeledContent {
                                TextField("", value: $item.value, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .focused($isFocused, equals: .value(item.id))
                            } label: {
                                Text("\(unit.unitExtension)/100g")
                                    .foregroundStyle(.gray)
                            }

                            LabeledContent {
                                TextField("", value: $item.weight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .focused($isFocused, equals: .weight(item.id))
                            } label: {
                                Text("grams")
                                    .foregroundStyle(.gray)
                            }
                            .onChange(of: isFocused) { oldValue, newValue in
                                if newValue == .value(item.id) || newValue == .weight(item.id) {
                                    withAnimation {
                                        proxy.scrollTo(item.id, anchor: .center)
                                    }
                                }
                            }
                        } header: {
                            HStack {
                                Text("Item \(index + 1)")
                                Spacer()
                                if index > 0 {
                                    Button("Remove", role: .destructive) {
                                        _ = withAnimation {
                                            items.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button("Add Item", systemImage: "plus") {
                        let item = EnergyData()
                        withAnimation {
                            items.append(item)
                        } completion: {
                            withAnimation {
                                isFocused = .value(item.id)
                                proxy.scrollTo(item.id, anchor: .top)
                            }
                        }
                    }
                }
                .navigationTitle(navigationTitle)
                .navigationSubtitle(navigationSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.defaultMinListRowHeight, 0)
                .scrollDismissesKeyboard(.interactively)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) {
                            if newValue != nil {
                                confirmClose.toggle()
                            } else {
                                dismiss()
                            }
                        }
                        .confirmationDialog("Close", isPresented: $confirmClose) {
                            Button("Discard", role: .destructive) {
                                dismiss()
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) {
                            guard let newValue else { return }
                            Task {
                                await viewModel.saveCalories(newValue, at: newDate)
                                dismiss()
                            }
                        }
                        .disabled(newValue == nil)
                    }
                }
                .safeAreaBar(
                    edge: .bottom,
                    content: {
                        if isFocused != nil {
                            HStack(spacing: 40) {
                                Spacer()
                                Button("Next", systemImage: "chevron.down") {
                                    switch isFocused {
                                    case .value(let uUID):
                                        isFocused = .weight(uUID)
                                    case .weight(let uUID):
                                        guard let index = items.firstIndex(where: { $0.id == uUID }) else {
                                            break
                                        }

                                        if index < items.count - 1 {
                                            isFocused = .value(items[index + 1].id)
                                        } else {
                                            let item = EnergyData()
                                            withAnimation {
                                                items.append(item)
                                            } completion: {
                                                withAnimation {
                                                    isFocused = .value(item.id)
                                                    proxy.scrollTo(item.id, anchor: .top)
                                                }
                                            }
                                        }
                                    case nil:
                                        break
                                    }
                                }
                                Button("Previous", systemImage: "chevron.up") {
                                    switch isFocused {
                                    case .value(let uUID):
                                        guard let index = items.firstIndex(where: { $0.id == uUID }) else {
                                            break
                                        }
                                        if index > 0 {
                                            isFocused = .weight(items[index - 1].id)
                                        }
                                    case .weight(let uUID):
                                        isFocused = .value(uUID)
                                    case nil:
                                        break
                                    }
                                }
                            }
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .padding(.vertical)
                            .padding(.horizontal, 24)
                        }
                    }
                )
                .onAppear {
                    isFocused = .value(items[0].id)
                }
                .onChange(of: items) { _, newItems in
                    countEnergy(for: newItems)
                }
            }
        }
        .interactiveDismissDisabled(newValue != nil)
    }

    private func countEnergy(for items: [EnergyData]) {
        let values = items.compactMap { item -> Double? in
            guard let value = item.value, let weight = item.weight else { return nil }
            return value * (weight / 100)
        }

        withAnimation {
            newValue = values.isEmpty ? nil : values.reduce(0, +)
        }
    }
}
