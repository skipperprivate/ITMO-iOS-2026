//
//  CityDetailView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

// Transparent: the hosting screen (Home pager, city preview) supplies the backdrop.
struct CityDetailView: View {
    let viewModel: CityDetailViewModel
    @Environment(SettingsStore.self) private var settingsStore
    @Environment(Router.self) private var router
    @Environment(ConnectivityMonitor.self) private var connectivity

    var body: some View {
        ScrollView {
            Group {
                switch viewModel.state {
                case .loading:
                    CityDetailSkeleton()
                case .failed(let error):
                    StateMessageView(error: error) {
                        Task { await viewModel.refresh() }
                    }
                    .padding(.top, 120)
                case .loaded(let snapshot):
                    // "Now" drives the hour strip and summary, so it has to move while the screen stays open.
                    TimelineView(.everyMinute) { context in
                        content(for: snapshot, now: context.date)
                    }
                }
            }
            .padding(.horizontal, 16)
            // Keeps the hero clear of the navigation bar's scroll-edge fade.
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .top) { refreshBanner }
        .animation(.snappy, value: viewModel.refreshError)
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadIfNeeded() }
        .onChange(of: connectivity.isConnected) { _, isConnected in
            guard isConnected else { return }
            Task { await viewModel.recoverAfterReconnect() }
        }
    }

    @ViewBuilder
    private var refreshBanner: some View {
        if let error = viewModel.refreshError {
            StatusBanner(error: error) {
                Task { await viewModel.refresh() }
            }
            .padding(.top, 4)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func content(for snapshot: CityWeatherSnapshot, now: Date) -> some View {
        let settings = settingsStore.settings

        return VStack(spacing: 14) {
            CityHeroView(
                snapshot: snapshot,
                summary: WeatherSummary.precipitation(for: snapshot, now: now),
                now: now,
                unit: settings.temperatureUnit
            )
            .padding(.bottom, 10)

            HourlyForecastView(
                entries: HourlyTimeline.entries(
                    hours: snapshot.upcomingHourly(from: now),
                    days: snapshot.daily,
                    highlightFirst: true,
                    current: snapshot.current
                ),
                timeZone: snapshot.city.timeZone,
                unit: settings.temperatureUnit
            )

            WeatherDetailsCarousel(
                current: snapshot.current,
                today: snapshot.today(now: now),
                timeZone: snapshot.city.timeZone,
                settings: settings,
                now: now
            )

            DailyForecastView(
                days: snapshot.upcomingDaily(from: now),
                calendar: snapshot.city.calendar,
                unit: settings.temperatureUnit
            ) { day in
                router.push(.dayDetail(snapshot: snapshot, date: day.date))
            }

            ForecastFooterView(updatedAt: viewModel.lastUpdated, now: now)
        }
    }
}

#if DEBUG
#Preview {
    CityDetailView(viewModel: CityDetailViewModel(
        city: PreviewSupport.city,
        weatherRepository: PreviewSupport.container.weatherRepository
    ))
    .previewOnBackdrop(padding: 0)
}

#Preview("Нет сети") {
    CityDetailView(viewModel: CityDetailViewModel(
        city: PreviewSupport.city,
        weatherRepository: MockWeatherRepository(failure: .offline)
    ))
    .previewOnBackdrop(isDaytime: true, padding: 0)
}
#endif
