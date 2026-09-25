//
//  NewEntryView.swift
//  Calories
//
//  Created by Radoslav Bley on 22/09/2026.
//

import SwiftUI

struct NewEntryView: View {
    @Environment(CaloriesViewModel.self) private var caloriesModel
    @State private var viewModel = NewEntryViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: FocusedField?

    @State private var newValueString: String = ""
    @State private var newWeightString: String = ""

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach($viewModel.items.enumerated(), id: \.element.id) { index, $item in
                        Section("Item \(index + 1)") {
                            NumberField("\(caloriesModel.unit.unitExtension)/100g", value: $item.value)
                            NumberField("grams", value: $item.weight)
                        }
                    }
                    .onDelete(perform: remove)
                }
                .navigationTitle(viewModel.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) {
                            if viewModel.newValue != nil {
                                viewModel.confirmClose.toggle()
                            } else {
                                dismiss()
                            }
                        }
                        .confirmationDialog("Close", isPresented: $viewModel.confirmClose) {
                            Button("Discard", role: .destructive) {
                                dismiss()
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) {
                            guard let value = viewModel.newValue else { return }
                            Task {
                                await caloriesModel.saveCalories(value, at: viewModel.newDate)
                                dismiss()
                            }
                        }
                        .disabled(viewModel.newValue == nil)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("Add Item", systemImage: "plus") {
                            viewModel.addItem(proxy, focus: $isFocused)
                        }
                    }
                }
                .onAppear {
                    isFocused = .value(viewModel.items[0].id)
                }
            }
        }
    }

    private func remove(at offsets: IndexSet) {
        if viewModel.items.count > 1 {
            viewModel.items.remove(atOffsets: offsets)
        } else {
            viewModel.items[0] = .init()
        }
    }
}

#Preview {
    NewEntryView()
        .environments()
}
