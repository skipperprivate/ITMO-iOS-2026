import SwiftUI

struct HomeView: View {

    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 28
                    ) {

                        searchBar

                        categories


                        if !viewModel.featuredEvents.isEmpty {
                            featuredSection
                        }

                        if viewModel.isLoading {
                            loadingView
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 16) {
                                Text("Не удалось загрузить мероприятия")
                                    .font(.headline)

                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Button("Повторить") {
                                    Task {
                                        await viewModel.load()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                        } else {
                            nearbyEventsSection
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .task(id: viewModel.selectedCategory) {
                await viewModel.load()
            }
            .navigationTitle("home.title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(.visible, for: .navigationBar)
            .preferredColorScheme(.dark)
    }

    private var searchBar: some View {
        SearchButton()
        .padding(.horizontal, 20)
    }

    private var categories: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(spacing: 10) {
                ForEach(
                    EventCategoryRu.allCases
                ) { category in

                    CategoryChip(
                        category: category,
                        isSelected:
                            viewModel.selectedCategory
                            == category
                    ) {
                        withAnimation(.easeInOut) {
                            viewModel.selectCategory(
                                category
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var content: some View {
        VStack(
            alignment: .leading,
            spacing: 30
        ) {

            if !viewModel.featuredEvents.isEmpty {
                featuredSection
            }

            nearbyEventsSection
        }
    }

    private var featuredSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            sectionHeader(
                title: "home.featured.title",
            )

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(spacing: 16) {
                    ForEach(
                        viewModel.featuredEvents
                    ) { event in

                        NavigationLink(value: AppRoute.eventDetails(event)) {
                            FeaturedEventCard(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var nearbyEventsSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            sectionHeader(
                title: "home.nearEvents",
            )

            if viewModel.filteredEvents.isEmpty {
                ContentUnavailableView(
                    "Мероприятия не найдены",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text(
                        "В выбранной категории пока нет мероприятий"
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredEvents) { event in
                        NavigationLink(
                            value: AppRoute.eventDetails(event)
                        ) {
                            EventCard(event: event)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("home.event.\(event.id)")
                        .onAppear {
                            if event.id == viewModel.filteredEvents.last?.id {
                                viewModel.requestNextPage()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                if viewModel.isLoadingMore {
                    ProgressView("Загружаем ещё...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                if let error = viewModel.paginationError {
                    VStack(spacing: 8) {
                        Text(error).font(.caption).foregroundStyle(.secondary)
                        Button("Повторить") {
                            viewModel.requestNextPage()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.white)

            Text("home.loadingEvents")
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.top, 80)
    }

    private func sectionHeader(title: LocalizedStringResource) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
