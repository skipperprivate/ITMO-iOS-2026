import SwiftUI

struct EventDetailsView: View {

    @State private var viewModel: EventDetailsViewModel

    init(viewModel: EventDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                eventImage

                VStack(alignment: .leading, spacing: 24) {
                    header

                    Divider()
                        .overlay(Color.white.opacity(0.1))

                    eventInformation

                    detailsSection

                    ticketSection
                }
                .padding(20)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .scrollIndicators(.hidden)
        .foregroundStyle(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Мероприятие")
                    .font(.headline)
            }
        }
        .task {
            viewModel.load()
            await viewModel.loadDetails()
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var eventImage: some View {
        GeometryReader { geometry in
            AsyncImage(url: viewModel.event.imageURL) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    imagePlaceholder
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }

                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
        }
        .frame(height: 250)
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.event.category.rawValue.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.purple)

                Text(viewModel.event.title)
                    .font(.system(size: 28, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(
                    systemName: viewModel.isFavorite
                        ? "heart.fill"
                        : "heart"
                )
                .font(.system(size: 22))
                .foregroundStyle(.purple)
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                viewModel.isFavorite
                    ? "favorite.delete"
                    : "favorite.add"
            )
            .accessibilityIdentifier("eventDetails.favorite")
        }
    }

    private var eventInformation: some View {
        VStack(alignment: .leading, spacing: 22) {
            informationRow(
                icon: "calendar",
                title: viewModel.event.date.formatted(
                    date: .long,
                    time: .shortened
                ),
                subtitle: "Дата и время"
            )

            informationRow(
                icon: "mappin.and.ellipse",
                title: viewModel.event.venue,
                subtitle: viewModel.event.address ?? viewModel.event.city
            )

            if let price = viewModel.event.price,
               !price.isEmpty {
                informationRow(
                    icon: "ticket",
                    title: price,
                    subtitle: "Стоимость"
                )
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("О мероприятии")
                .font(.title3.bold())

            if viewModel.isLoadingDetails {
                ProgressView("Загружаем подробности...")
                    .tint(.purple)
            }

            if let description = viewModel.event.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .textSelection(.enabled)
            } else if !viewModel.isLoadingDetails && viewModel.detailsError == nil {
                Text("Организатор не предоставил описание мероприятия.")
                    .foregroundStyle(.secondary)
            }

            if let error = viewModel.detailsError {
                Text("error.cantShow.details\(error)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Повторить") {
                    Task { await viewModel.loadDetails() }
                }
                .tint(.purple)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var ticketSection: some View {
        if let url = viewModel.event.ticketURL {
            Link(destination: url) {
                Label("Открыть билеты на Ticketmaster", systemImage: "ticket")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityIdentifier("eventDetails.tickets")
        }
    }

    private func informationRow(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.purple)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
