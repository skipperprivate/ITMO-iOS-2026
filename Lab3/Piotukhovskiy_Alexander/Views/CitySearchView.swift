import SwiftUI

struct CitySearchView: View {
    @EnvironmentObject private var weather: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let cities = ["Moscow", "Saint-Petersburg", "Berlin"]

    private var filteredCities: [String] {
        searchText.isEmpty ? cities : cities.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filteredCities, id: \.self) { city in
            Button(city) {
                weather.selectCity(city)
                dismiss()
            }
        }
        .searchable(text: $searchText, prompt: "City name")
        .navigationTitle("Find city")
    }
}
