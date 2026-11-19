import SwiftUI

struct EventCard: View {
    let event: Event

    var body: some View {
        HStack(spacing: 14) {
            eventImage
            eventInformation
            Spacer()
            disclosureIndicator
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }

    private var eventImage: some View {
        AsyncImage(url: event.imageURL) { phase in
            switch phase {
            case .empty:
                imageBackground

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                imageBackground
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    }

            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 92, height: 92)
        .clipShape(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private var imageBackground: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
    }

    private var eventInformation: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(event.category.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.purple)

            Text(event.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Label(
                event.date.formatted(
                    .dateTime.weekday(.abbreviated).hour().minute()
                ),
                systemImage: "calendar"
            )

            Label(event.venue, systemImage: "mappin.and.ellipse")
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
    }

    private var disclosureIndicator: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}
