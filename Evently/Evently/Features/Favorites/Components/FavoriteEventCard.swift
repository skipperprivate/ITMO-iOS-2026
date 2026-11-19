import SwiftUI

struct FavoriteEventCard: View {

    let event: FavoriteEvent
    let onEditNote: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(value: AppRoute.eventDetails(event.asEvent)) {
                eventImage
                eventInformation
            }
            .buttonStyle(.plain)

            Spacer()

            actionButtons
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("favorites.event.\(event.eventId)")
    }

    private var eventImage: some View {
        AsyncImage(url: event.imageURL) { phase in
            switch phase {
            case .empty:
                imagePlaceholder

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                imagePlaceholder.overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray)
                }

            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 92, height: 92)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
    }

    private var eventInformation: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(event.title)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(event.venue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(event.city)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !event.note.isEmpty {
                Label(
                    event.note,
                    systemImage: "note.text"
                )
                .font(.caption)
                .foregroundStyle(.purple)
                .lineLimit(2)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: onEditNote) {
                Image(
                    systemName: event.note.isEmpty
                        ? "note.text"
                        : "note.text.badge.plus"
                )
                .font(.system(size: 18))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Редактировать заметку")

            Button(action: onDelete) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.purple)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("favorite.delete")
            .accessibilityIdentifier("favorites.delete.\(event.eventId)")
        }
    }
}
