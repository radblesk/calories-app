//
//  NewEntryView.swift
//  Calories
//
//  Created by Radoslav Bley on 21/09/2026.
//

import SwiftUI

struct NewEntryView: View {
    @Environment(CaloriesViewModel.self) private var caloriesModel
    @State private var viewModel = NewEntryViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: FocusedField?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    Section {
                        VStack {
                            Image(systemName: "fork.knife")
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
                        DatePicker("", selection: $viewModel.newDate, displayedComponents: .date)
                    } label: {
                        Text("Date")
                            .foregroundStyle(.gray)
                    }

                    LabeledContent {
                        DatePicker("", selection: $viewModel.newDate, displayedComponents: .hourAndMinute)
                    } label: {
                        Text("Time")
                            .foregroundStyle(.gray)
                    }

                    ForEach($viewModel.items.enumerated(), id: \.element.id) { index, $item in
                        Section {
                            LabeledContent {
                                TextField("", value: $item.value, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .submitLabel(.next)
                                    .focused($isFocused, equals: .value(item.id))
                            } label: {
                                Text("\(caloriesModel.unit.unitExtension)/100g")
                                    .foregroundStyle(.gray)
                            }

                            LabeledContent {
                                TextField("", value: $item.weight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .submitLabel(.done)
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
                                            viewModel.items.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button("Add Item", systemImage: "plus") {
                        viewModel.addItem(proxy, focus: $isFocused)
                    }
                }
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.navigationSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .scrollDismissesKeyboard(.interactively)
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
                            guard let newValue = viewModel.newValue else { return }
                            Task {
                                await caloriesModel.storeCalories(newValue, at: viewModel.newDate)
                                dismiss()
                            }
                        }
                        .disabled(viewModel.newValue == nil)
                    }
                }
                .safeAreaBar(
                    edge: .bottom,
                    content: {
                        if isFocused != nil {
                            HStack(spacing: 40) {
                                Spacer()
                                Button("Next", systemImage: "chevron.down") {
                                    viewModel.nextItem(proxy, focus: $isFocused)
                                }
                                Button("Previous", systemImage: "chevron.up") {
                                    viewModel.previousItem(proxy, focus: $isFocused)
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
                    isFocused = .value(viewModel.items[0].id)
                }
            }
        }
        .interactiveDismissDisabled(viewModel.newValue != nil)
    }
}
