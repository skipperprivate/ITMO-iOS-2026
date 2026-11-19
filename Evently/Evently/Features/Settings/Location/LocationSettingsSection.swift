import SwiftUI

struct LocationSettingsSection: View {
    let store: LocationStore

    @State private var service = LocationService()
    @State private var isCityPickerPresented = false

    private var isUnsupportedCountry: Bool {
        guard let code = store.countryCode else { return false }
        return !TicketmasterCities.supportedCountryCodes.contains(code)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Локация")
                .font(.title2.bold())

            selectedCityCard

            if let error = service.errorMessage {
                message(
                    error,
                    symbol: "exclamationmark.circle",
                    accessibilityID: "location.error"
                )
            }

            if isUnsupportedCountry {
                message(
                    "Для выбранной страны Ticketmaster может не предоставлять мероприятия. " +
                        "Сам город определён корректно.",
                    symbol: "info.circle",
                    accessibilityID: "location.unsupportedCountry"
                )
            }

            Button {
                service.errorMessage = nil
                isCityPickerPresented = true
            } label: {
                Text("Выбрать город")
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
            .buttonStyle(.bordered)
            .tint(.purple)
            .disabled(service.isLocating)
            .accessibilityIdentifier("location.search")

            Button {
                service.useCurrentLocation(store: store)
            } label: {
                Text(service.isLocating ? "Определяем местоположение…" : "Определить автоматически")
                    .contentTransition(.opacity)
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .disabled(service.isLocating)
            .accessibilityIdentifier("location.detect")

            if store.city != nil {
                Button {
                    store.clear()
                    service.clearProposal()
                    service.errorMessage = nil
                } label: {
                    Text("Сбросить выбранный город")
                        .frame(maxWidth: .infinity, minHeight: 42)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .disabled(service.isLocating)
                .accessibilityIdentifier("location.reset")
            }
        }
        .sheet(isPresented: $isCityPickerPresented) {
            CityPickerView(store: store)
        }
        .onChange(of: store.selectionKey) {
            service.errorMessage = nil
        }
    }

    private var selectedCityCard: some View {
        HStack(spacing: 14) {
            Image(systemName: isUnsupportedCountry ? "mappin.slash" : "mappin.and.ellipse")
                .font(.title2)
                .foregroundStyle(isUnsupportedCountry ? Color.secondary : Color.purple)
                .frame(width: 44, height: 44)
                .background(
                    isUnsupportedCountry ? Color.secondary.opacity(0.09) : Color.purple.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text("settings.currentTown")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(store.displayName)
                    .font(.title3.bold())
                    .accessibilityIdentifier("location.selectedCity")

                if store.city == nil {
                    Text("По умолчанию показываются события США")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if isUnsupportedCountry {
                    Text("Нет подтверждённого покрытия Ticketmaster")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func message(
        _ text: String,
        symbol: String,
        accessibilityID: String
    ) -> some View {
        Label(text, systemImage: symbol)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .accessibilityIdentifier(accessibilityID)
    }
}
