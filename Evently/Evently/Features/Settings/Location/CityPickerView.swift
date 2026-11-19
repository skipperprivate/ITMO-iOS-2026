import SwiftUI

struct CityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    @State private var query = ""

    let store: LocationStore

    private var filteredCities: [TicketmasterCity] {
        TicketmasterCities.suggestions.filter { $0.matches(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredCities.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(filteredCities) { city in
                            Button {
                                isSearchFocused = false
                                store.select(city: city.name, countryCode: city.countryCode)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(city.name)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)

                                        Text(city.country)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if store.city == city.name &&
                                        store.countryCode == city.countryCode {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                            .accessibilityLabel("Выбранный город")
                                    }
                                }
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("location.city.\(city.countryCode).\(city.name)")
                        }
                    } header: {
                        Text("Доступные города")
                    } footer: {
                        Text("ticketmaster.town.list.condition")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded { isSearchFocused = false }
            )
            .navigationTitle("Выбор города")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Название города или страны")
            .searchFocused($isSearchFocused)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        isSearchFocused = false
                        dismiss()
                    }
                }
            }
        }
        .tint(.purple)
    }
}
