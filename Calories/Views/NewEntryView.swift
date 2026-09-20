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

    @State private var newValue: Double? = nil
    @State private var items: [CalorieData] = [.init()]
    @State private var newDate: Date = .now
    @FocusState private var isFocused: FocusedField?

    @State private var confirmClose: Bool = false

    enum FocusedField: Hashable {
        case kcal(UUID)
        case weight(UUID)
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

                    if let newValue {
                        LabeledContent {
                            Text("\(newValue.formatted(.number.precision(.fractionLength(2)))) kcal")
                                .contentTransition(.numericText(value: newValue))
                        } label: {
                            Text("Total")
                                .foregroundStyle(.gray)
                        }
                    }

                    ForEach($items.enumerated(), id: \.element.id) { index, $item in
                        Section {
                            LabeledContent {
                                TextField("", value: $item.kcal, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .focused($isFocused, equals: .kcal(item.id))
                            } label: {
                                Text("kcal/100g")
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
                                if newValue == .kcal(item.id) || newValue == .weight(item.id) {
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
                        let item = CalorieData()
                        withAnimation {
                            items.append(item)
                        } completion: {
                            withAnimation {
                                isFocused = .kcal(item.id)
                                proxy.scrollTo(item.id, anchor: .top)
                            }
                        }
                    }
                }
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
                .onAppear {
                    isFocused = .kcal(items[0].id)
                }
                .onChange(of: items) { _, newItems in
                    countCalories(for: newItems)
                }
            }
        }
        .interactiveDismissDisabled(newValue != nil)
    }

    private func countCalories(for items: [CalorieData]) {
        let values = items.compactMap { item -> Double? in
            guard let calories = item.kcal, let weight = item.weight else { return nil }
            return calories * (weight / 100)
        }

        withAnimation {
            newValue = values.isEmpty ? nil : values.reduce(0, +)
        }
    }
}
